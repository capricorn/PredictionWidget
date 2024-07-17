//
//  WidgetCache.swift
//  PredictionMarketWidgetExtension
//
//  Created by Collin Palmer on 7/15/24.
//

import Foundation
import SwiftData


extension PIJSONMarketContract {
    /*
    var contract: MarketContract {
        MarketContract(id: self.id, name: self.shortName, cents: self.lastTradePrice, change: nil)
    }
     */
    func contract(market: PreviousMarketDataModel) -> ContractEntryModel {
        return ContractEntryModel(id: self.id, price: self.lastTradePrice ?? 0, name: self.shortName, market: market)
    }
}

/*
private extension ContractEntryModel {
    var marketContract: MarketContract {
        MarketContract(id: self.id, name: self.name, cents: self.price, change: nil)
    }
}
 */
 
class WidgetCache {
    static let minimumStaleElapsedTime: TimeInterval = 60*15
    static let shared: WidgetCache = WidgetCache()
    let modelContext: ModelContext
    
    enum State {
        case empty
        case currentSet(current: PreviousMarketDataModel)
        case currentAndPreviousSet(current: PreviousMarketDataModel, previous: PreviousMarketDataModel)
    }
    
    func market(marketId: Int) -> Market? {
        switch state(marketId: marketId) {
        case .empty:
            return nil
        case .currentSet(let current):
            let contracts = current.contracts.map {
                // TODO: Need to account for non-existent price
                MarketContract(id: $0.id, name: $0.name, cents: $0.price, change: nil)
            }
            return Market(id: marketId, name: "", contracts: contracts)
        case .currentAndPreviousSet(let current, let previous):
            let currContracts = current.contracts.sorted(by: { $0.id < $1.id })
            let prevContracts = previous.contracts.sorted(by: { $0.id < $1.id })
            
            let contracts = zip(currContracts, prevContracts).map {
                let (curr, prev) = $0
                return MarketContract(id: curr.id, name: curr.name, cents: curr.price, change: curr.price - prev.price)
            }
            
            return Market(id: marketId, name: "", contracts: contracts)
        }
    }
    
    func currentEntry(marketId: Int) -> PreviousMarketDataModel? {
        var descriptor = FetchDescriptor(predicate: #Predicate<PreviousMarketDataModel> { model in
            model.marketId == marketId && model.entryType == "\(marketId)_current"
        })
        //descriptor.relationshipKeyPathsForPrefetching = [\.contracts]
        return try? modelContext.fetch(descriptor).first
    }
    
    func previousEntry(marketId: Int) -> PreviousMarketDataModel? {
        return try? modelContext.fetch(FetchDescriptor(predicate: #Predicate<PreviousMarketDataModel> { model in
            model.marketId == marketId && model.entryType == "\(marketId)_previous"
        })).first
    }
    
    func state(marketId: Int) -> State {
        let curr = currentEntry(marketId: marketId)
        let prev = previousEntry(marketId: marketId)
        switch (curr, prev) {
            case (nil,nil):
                return .empty
            case (let current, nil) where current != nil:
                return .currentSet(current: current!)
            case (let current, let previous) where current != nil && previous != nil:
                return .currentAndPreviousSet(current: current!, previous: previous!)
            default:
                // TODO: Testing this..?
                fatalError("Illegal cache state: \(String(describing: curr)) \(String(describing: prev))")
        }
    }
    
    func lastModified(marketId: Int) -> Date? {
        currentEntry(marketId: marketId)?.refreshDate
    }
    
    func stale(marketId: Int, now: Date = .now) -> Bool {
        if let lastModified = lastModified(marketId: marketId), now.timeIntervalSince(lastModified) <= WidgetCache.minimumStaleElapsedTime {
            return false
        }
        
        return true
    }
    
    init(configuration: ModelConfiguration = ModelConfiguration()) {
        self.modelContext = ModelContext(try! ModelContainer(for: PreviousMarketDataModel.self, ContractEntryModel.self, MarketEntryModel.self, configurations: configuration))
    }
    
    // TODO: Write cache tests
    func insert(_ marketData: PIJSONMarket, now: Date = .now) throws {
        let entry = PreviousMarketDataModel(marketId: marketData.id, refreshDate: now, entryType: .current)
        // TODO: Better approach
        entry.entryType = "\(marketData.id)_current"
        
        switch state(marketId: entry.marketId) {
        case .empty:
            try modelContext.transaction {
                modelContext.insert(entry)
                
                for contract in marketData.contracts {
                    //modelContext.insert(contract.contract(market: entry))
                    let marketContract = contract.contract(market: entry)
                    entry.contracts.append(marketContract)
                }
            }
        case .currentSet(let current):
            if stale(marketId: entry.marketId, now: now) {
                try modelContext.transaction {
                    current.entryType = "\(entry.marketId)_previous"
                    modelContext.insert(entry)
                    
                    for contract in marketData.contracts {
                        //modelContext.insert(contract.contract(market: entry))
                        let marketContract = contract.contract(market: entry)
                        entry.contracts.append(marketContract)
                    }
                }
            }
        case .currentAndPreviousSet(let current, let previous):
            if stale(marketId: entry.marketId, now: now) {
                try modelContext.transaction {
                    // NB. Required as cascade delete doesn't seem to apply in a transaction...
                    // see: https://forums.developer.apple.com/forums/thread/740649
                    for contract in previous.contracts {
                        modelContext.delete(contract)
                    }
                    
                    modelContext.delete(previous)
                    current.entryType = "\(entry.marketId)_previous"
                    modelContext.insert(entry)

                    for contract in marketData.contracts {
                        //modelContext.insert(contract.contract(market: entry))
                        let marketContract = contract.contract(market: entry)
                        entry.contracts.append(marketContract)
                    }
                }
            }
        }
    }
}

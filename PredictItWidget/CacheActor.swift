//
//  CacheActor.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/12/24.
//

import Foundation
import SwiftData

actor CacheActor {
    static let shared: CacheActor = CacheActor()
    private let modelContext: ModelContext
    
    init(configuration: ModelConfiguration = ModelConfiguration()) {
        self.modelContext = ModelContext(try! ModelContainer(for: PreviousMarketDataModel.self, ContractEntryModel.self, configurations: configuration))
    }
    
    struct CachedTooRecentlyError: Error {}
    static let minimumCacheInterval: TimeInterval = 1*60
    
    func guardCachedRecently(prevCacheDate: Date, now: Date) throws {
        if now.timeIntervalSince(prevCacheDate) < CacheActor.minimumCacheInterval {
            throw CachedTooRecentlyError()
        }
    }
    
    func clearCache() throws {
        try modelContext.delete(model: PreviousMarketDataModel.self)
    }
    
    var state: PreviousMarketDataModel.CacheState {
        // Query to find current and previous
        let currType = PreviousMarketDataModel.EntryType.current.rawValue
        let pred = #Predicate<PreviousMarketDataModel> { (model: PreviousMarketDataModel) in
            model.entryType == currType
        }
        let query = FetchDescriptor(predicate: pred)
        let results = try! modelContext.fetch(query)
        
        if results.isEmpty {
            return .empty
        }
        
        let prevType = PreviousMarketDataModel.EntryType.previous.rawValue
        let prevPred = #Predicate<PreviousMarketDataModel> { (model: PreviousMarketDataModel) in
            model.entryType == prevType
        }
        let prevQuery = FetchDescriptor(predicate: prevPred)
        let prevResults = try! modelContext.fetch(prevQuery)
        
        if prevResults.isEmpty {
            return .currentSet(results.first!)
        }
        
        return .currentAndPreviousSet(current: results.first!, previous: prevResults.first!)
    }
    
    // Compute cache state here and perform insert accordingly
    func insertCache(marketData: PIJSONMarket, now: Date = Date.now) throws {
        let newCurr = PreviousMarketDataModel(marketId: marketData.id, refreshDate: now, entryType: .current)

        switch self.state {
        case .empty:
            try modelContext.transaction {
                modelContext.insert(newCurr)
                
                let contracts = marketData.contracts.map {
                    // TODO: Support nil price
                    let entry = ContractEntryModel(id: $0.id, price: $0.lastTradePrice ?? 0, name: $0.shortName, market: newCurr)
                    return entry
                }
                
                for contract in contracts {
                    modelContext.insert(contract)
                }
            }
        case .currentSet(let prev):
            try guardCachedRecently(prevCacheDate: prev.refreshDate, now: now)
            
            try modelContext.transaction {
                prev.entryType = PreviousMarketDataModel.EntryType.previous.rawValue
                modelContext.insert(newCurr)
                
                let contracts = marketData.contracts.map {
                    // TODO: Support nil price
                    let entry = ContractEntryModel(id: $0.id, price: $0.lastTradePrice ?? 0, name: $0.shortName, market: newCurr)
                    return entry
                }
                
                for contract in contracts {
                    modelContext.insert(contract)
                }
            }
        case .currentAndPreviousSet(let current, let previous):
            try guardCachedRecently(prevCacheDate: previous.refreshDate, now: now)
            try modelContext.transaction {
                modelContext.delete(previous)
                current.entryType = PreviousMarketDataModel.EntryType.previous.rawValue
                modelContext.insert(newCurr)
                
                let contracts = marketData.contracts.map {
                    // TODO: Support nil price
                    let entry = ContractEntryModel(id: $0.id, price: $0.lastTradePrice ?? 0, name: $0.shortName, market: newCurr)
                    return entry
                }
                
                for contract in contracts {
                    modelContext.insert(contract)
                }
            }
        }
    }
}

//
//  CacheActor.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/12/24.
//

import Foundation
import SwiftData

// Use this to isolate access to the cache?
// TODO: Global actor options
//@ModelActor
actor CacheActor {
    static let shared: CacheActor = CacheActor()
    private let modelContext: ModelContext
    
    init(configuration: ModelConfiguration = ModelConfiguration()) {
        self.modelContext = ModelContext(try! ModelContainer(for: PreviousMarketDataModel.self, ContractEntryModel.self, configurations: configuration))
    }
    
    struct CachedTooRecentlyError: Error {}
    
    func guardCachedRecently(prevCacheDate: Date, now: Date) throws {
        if now.timeIntervalSince(prevCacheDate) < 1*60 {
            throw CachedTooRecentlyError()
        }
    }
    
    func clearCache() throws {
        modelContext.container.deleteAllData()
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
        let newCurr = PreviousMarketDataModel(marketId: marketData.id, refreshDate: now, entryType: .current, contracts: [])
        let contracts = marketData.contracts.map {
            // TODO: Support nil price
            let entry = ContractEntryModel(id: $0.id, price: $0.lastTradePrice ?? 0, name: $0.shortName)
            //entry.market = newCurr
            return entry
        }
        
        newCurr.contracts = contracts

        switch try PreviousMarketDataModel.cacheState(selectedMarketId: marketData.id, context: modelContext) {
        case .empty:
            //let newCurr = PreviousMarketDataModel(marketId: marketData.id, refreshDate: now, entryType: .current, contracts: contracts)
            modelContext.insert(newCurr)
        case .currentSet(let prev):
            try guardCachedRecently(prevCacheDate: prev.refreshDate, now: now)
            // TODO: Guard against cache being invalidated too quickly (ie require say 3 min between now and then)
            //let newCurr = PreviousMarketDataModel(marketId: marketData.id, refreshDate: now, entryType: .current, contracts: contracts)
            try modelContext.transaction {
                prev.entryType = PreviousMarketDataModel.EntryType.previous.rawValue
                modelContext.insert(newCurr)
            }
        case .currentAndPreviousSet(let current, let previous):
            try guardCachedRecently(prevCacheDate: previous.refreshDate, now: now)
            //let newCurr = PreviousMarketDataModel(marketId: marketData.id, refreshDate: now, entryType: .current, contracts: contracts)
            try modelContext.transaction {
                modelContext.delete(previous)
                current.entryType = PreviousMarketDataModel.EntryType.previous.rawValue
                modelContext.insert(newCurr)
            }
        }
    }
}

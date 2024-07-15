//
//  WidgetCache.swift
//  PredictionMarketWidgetExtension
//
//  Created by Collin Palmer on 7/15/24.
//

import Foundation
import SwiftData

class WidgetCache {
    static let shared: WidgetCache = WidgetCache()
    let modelContext: ModelContext
    
    enum State {
        case empty
        case currentSet(current: PreviousMarketDataModel)
        case currentAndPreviousSet(current: PreviousMarketDataModel, previous: PreviousMarketDataModel)
    }
    
    func currentEntry(marketId: Int) -> PreviousMarketDataModel? {
        return try? modelContext.fetch(FetchDescriptor(predicate: #Predicate<PreviousMarketDataModel> { model in
            model.marketId == marketId && model.entryType == "current"
        })).first
    }
    
    func previousEntry(marketId: Int) -> PreviousMarketDataModel? {
        return try? modelContext.fetch(FetchDescriptor(predicate: #Predicate<PreviousMarketDataModel> { model in
            model.marketId == marketId && model.entryType == "previous"
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
        if let lastModified = lastModified(marketId: marketId), now.timeIntervalSince(lastModified) <= 15*60 {
            return false
        }
        
        return true
    }
    
    init(configuration: ModelConfiguration = ModelConfiguration()) {
        self.modelContext = ModelContext(try! ModelContainer(for: PreviousMarketDataModel.self, ContractEntryModel.self, MarketEntryModel.self, configurations: configuration))
    }
    
    // TODO: Write cache tests
    func insert(_ entry: PreviousMarketDataModel, now:Date = .now) throws {
        switch state(marketId: entry.marketId) {
        case .empty:
            modelContext.insert(entry)
        case .currentSet(let current):
            if stale(marketId: entry.marketId) {
                try modelContext.transaction {
                    entry.entryType = "current"
                    modelContext.insert(entry)
                    current.entryType = "previous"
                }
            }
        case .currentAndPreviousSet(let current, let previous):
            if stale(marketId: entry.marketId) {
                try modelContext.transaction {
                    entry.entryType = "current"
                    modelContext.insert(entry)
                    current.entryType = "previous"
                    modelContext.delete(previous)
                }
            }
        }
    }
}

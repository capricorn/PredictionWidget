//
//  TimelineProvider.swift
//  PredictionMarketWidgetExtension
//
//  Created by Collin Palmer on 7/14/24.
//

import Foundation
import WidgetKit
import SwiftUI
import SwiftData

private extension PIJSONMarketContract {
    var contract: MarketContract {
        MarketContract(id: self.id, name: self.shortName, cents: self.lastTradePrice, change: nil)
    }
}

struct Provider: AppIntentTimelineProvider {
    let modelContext: ModelContext
    static let queue = DispatchQueue(label: "PredictionWidgetQueue")
    static let group = DispatchGroup()
    static let cache = WidgetCache()
    
    func placeholder(in context: Context) -> MarketEntry {
        MarketEntry(date: Date.now, type: .market(Market(id: 0, name: "Test Market", contracts: [])))
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> MarketEntry {
        MarketEntry(date: Date.now, type: .market(Market(id: 0, name: "Test Market", contracts: [])))
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<MarketEntry> {
        return await withUnsafeContinuation { (continuation: UnsafeContinuation<Timeline<MarketEntry>, Never>) in
            // Instead, pass an escaping closure here; it'll handle the continuation
            // TODO: Simpler approach?
            // TODO: CheckedContinuation?
            Provider.queue.sync {
                Provider.group.enter()
                // TODO: Need to block utnil
                //let defaults = UserDefaults.predictionWidget
                var entries: [MarketEntry] = []
                let finish = { (entry: MarketEntry) in
                    continuation.resume(returning: Timeline(entries: [entry], policy: .after(Date.now.addingTimeInterval(60*15))))
                    Provider.group.leave()
                }
                
                do {
                    if let marketId = configuration.selectedMarket?.id {
                        try PredictItAPI.fetchMarketData(marketId: "\(marketId)") { marketData in
                            guard let marketData else {
                                let entry = MarketEntry(date: .now, type: .error)
                                finish(entry)
                                return
                            }
                            
                            let entry = MarketEntry(
                            date: Date.now,
                            type: .market(Market(
                                id: marketData.id,
                                name: marketData.shortName,
                                contracts: marketData.contracts.map({$0.contract}))))
                            
                            finish(entry)
                        }
                        
                        return
                    } else {
                        entries.append(MarketEntry(date: .now, type: .market(nil)))
                    }
                } catch {
                    entries.append(MarketEntry(date: .now, type: .error))
                }
                
                finish(entries[0])
            }
            
            Provider.group.wait()
        }
    }
}

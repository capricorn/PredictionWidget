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
    
    func placeholder(in context: Context) -> MarketEntry {
        MarketEntry(date: Date.now, type: .market(Market(id: 0, name: "Test Market", contracts: [])))
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> MarketEntry {
        MarketEntry(date: Date.now, type: .market(Market(id: 0, name: "Test Market", contracts: [])))
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<MarketEntry> {
        let defaults = UserDefaults.predictionWidget
        var entries: [MarketEntry] = []
        
        do {
            if let marketId = configuration.selectedMarket?.id {
                let marketData = try await PredictItAPI.fetchMarketData(marketId: "\(marketId)")
                let entry = MarketEntry(
                    date: Date.now,
                    type: .market(Market(
                        id: marketData.id,
                        name: marketData.shortName,
                        contracts: marketData.contracts.map({$0.contract}))))
                entries.append(entry)
            } else {
                entries.append(MarketEntry(date: .now, type: .market(nil)))
            }
        } catch {
            entries.append(MarketEntry(date: .now, type: .error))
        }
        
        return Timeline(entries: entries, policy: .after(Date.now.addingTimeInterval(60*15)))
    }
}

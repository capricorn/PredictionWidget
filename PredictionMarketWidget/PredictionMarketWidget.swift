//
//  PredictionMarketWidget.swift
//  PredictionMarketWidget
//
//  Created by Collin Palmer on 7/6/24.
//

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
        
        if let marketId = defaults?.value(.widgetMarket) as? Int {
            do {
                let marketData = try await PredictItAPI.fetchMarketData(marketId: "\(marketId)")
                // TODO
                try await CacheActor.shared.insertCache(marketData: marketData, now: .now)
                // TODO: New timeline approach (just to indicate that a valid market exists)
                // May not even need these enums
                let entry = MarketEntry(date: Date.now, type: .market(Market(id: marketData.id, name: marketData.shortName, contracts: marketData.contracts.map({$0.contract}))))
                entries.append(entry)
            } catch {
                print("Failed timeline update: \(error)")
            }
        } else {
            entries.append(MarketEntry(date: .now, type: .market(nil)))
        }
        
        return Timeline(entries: entries, policy: .after(Date.now.addingTimeInterval(60*15)))

        /*
        if let marketId = defaults?.value(.widgetMarket) as? Int {
            do {
                let market = try await PredictItAPI.fetchMarketData(marketId: "\(marketId)")
                let entry = MarketEntry(date: Date.now, type: .market(Market(id: market.id, name: market.shortName, contracts: market.contracts.map({$0.contract}))))
                entries.append(entry)
            } catch {
                entries.append(MarketEntry(date: .now, type: .error))
            }
        } else {
            entries.append(MarketEntry(date: .now, type: .market(nil)))
        }
         */

        return Timeline(entries: entries, policy: .after(Date.now.addingTimeInterval(60*15)))
    }
}



struct PredictionMarketWidget: Widget {
    let kind: String = "PredictionMarketWidget"
    let context = ModelContext(try! ModelContainer(for: PreviousMarketDataModel.self, ContractEntryModel.self, configurations: ModelConfiguration()))
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider(modelContext: context)) { entry in
            PredictionMarketWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .environment(\.modelContext, context)
        }
        .supportedFamilies([.systemSmall])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    PredictionMarketWidget()
} timeline: {
    MarketEntry(
        date: Date.now,
        type: .market(Market(
            id: 10,
            name: "Democratic 2024 presidential nominee?",  // Shortnmae
            contracts: [
                MarketContract(id: 0, name: "Trump", cents: 64, change: nil),
                MarketContract(id: 1, name: "Biden", cents: 33, change: nil),
            ])))
     MarketEntry(
        date: Date.now,
        type: .market(nil))
    MarketEntry(
       date: Date.now,
       type: .error)
    MarketEntry(
        date: Date.now,
        type: .market(Market(
            id: 10,
            name: "Democratic 2024 presidential nominee?",  // Shortnmae
            contracts: [
                MarketContract(id: 0, name: "Trump", cents: 64, change: nil),
                MarketContract(id: 1, name: "Biden", cents: 33, change: 8),
                MarketContract(id: 1, name: "Jeb", cents: 33, change: -4),
            ])))
}

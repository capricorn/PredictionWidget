//
//  PredictionMarketWidget.swift
//  PredictionMarketWidget
//
//  Created by Collin Palmer on 7/6/24.
//

import WidgetKit
import SwiftUI

private extension PIJSONMarketContract {
    var contract: MarketContract {
        MarketContract(id: self.id, name: self.shortName, cents: self.lastTradePrice)
    }
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MarketEntry {
        MarketEntry(date: Date.now, configuration: ConfigurationAppIntent(), type: .market(Market(id: 0, name: "Test Market", contracts: [])))
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> MarketEntry {
        MarketEntry(date: Date.now, configuration: ConfigurationAppIntent(), type: .market(Market(id: 0, name: "Test Market", contracts: [])))
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<MarketEntry> {
        let defaults = UserDefaults.predictionWidget
        
        // What was the rule for async requests again..?
        // TODO: Error handling
        var entries: [MarketEntry] = []
        
        if let marketId = defaults?.value(.widgetMarket) as? Int {
            do {
                let market = try await PredictItAPI.fetchMarketData(marketId: "\(marketId)")
                // TODO: Map contracts
                entries.append(MarketEntry(date: Date.now, configuration: configuration, type: .market(Market(id: market.id, name: market.shortName, contracts: market.contracts.map({$0.contract})))))
            } catch {}
        }

        return Timeline(entries: entries, policy: .after(Date.now.addingTimeInterval(60*15)))
    }
}

struct MarketContract: Identifiable {
    let id: Int
    let name: String
    let cents: Int?
}

struct Market: Identifiable {
    let id: Int
    let name: String
    let contracts: [MarketContract]
}

enum EntryType {
    /// `nil` if no market is selected.
    case market(Market?)
    case error
}

// TODO: -- define necessary fields
struct MarketEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let type: EntryType
}

struct PredictionMarketWidgetEntryView : View {
    var entry: Provider.Entry
    
    var contracts: [MarketContract] {
        switch entry.type {
        case .market(let market):
            if let market {
                return Array(market.contracts.sorted(by: { ($0.cents ?? 0) > ($1.cents ?? 0) }).prefix(3))
            } else {
                return []
            }
        default:
            return []
        }
    }
    
    var refreshTimestamp: some View {
        Text("\(Image(systemName: "clock.arrow.2.circlepath")) \(entry.date.formatted())")
            .font(.system(size: 8).weight(.light))
    }

    var body: some View {
        VStack(alignment: .leading) {
            switch entry.type {
            case .market(let market):
                if let market {
                    Text(market.name)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .font(.caption.bold())
                        .padding(.bottom, 8)
                    ForEach(contracts) { contract in
                        HStack {
                            Text(contract.name.uppercased())
                                .font(.caption2.smallCaps())
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding(.bottom, 2)
                            Spacer()
                            Text("\(contract.cents!)¢")
                                .monospaced()
                        }
                        .font(.caption2)
                    }
                    Spacer()
                    refreshTimestamp
                } else {
                    TimestampContainerView(entry: entry) {
                        Text("No market selected.")
                    }
                }
            case .error:
                TimestampContainerView(entry: entry) {
                    Text("Market fetch failed.")
                }
            }
        }
    }
}

struct PredictionMarketWidget: Widget {
    let kind: String = "PredictionMarketWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            PredictionMarketWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
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
        configuration: .smiley,
        type: .market(Market(
            id: 10,
            name: "Democratic 2024 presidential nominee?",  // Shortnmae
            contracts: [
                MarketContract(id: 0, name: "Trump", cents: 64),
                MarketContract(id: 1, name: "Biden", cents: 33),
            ])))
     MarketEntry(
        date: Date.now,
        configuration: .smiley,
        type: .market(nil))
    MarketEntry(
       date: Date.now,
       configuration: .smiley,
       type: .error)
}

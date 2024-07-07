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
        MarketEntry(date: Date.now, configuration: ConfigurationAppIntent(), name: "Test Market", contracts: [])
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> MarketEntry {
        MarketEntry(date: Date.now, configuration: ConfigurationAppIntent(), name: "Test Market", contracts: [])
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<MarketEntry> {
        //var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        /*
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }
         */
        
        // What was the rule for async requests again..?
        // TODO: Error handling
        var entries: [MarketEntry] = []
        do {
            let market = try await PredictItAPI.fetchMarketData(marketId: "7057")
            // TODO: Map contracts
            entries.append(MarketEntry(date: Date.now, configuration: configuration, name: market.shortName, contracts: market.contracts.map({$0.contract})))
        } catch {}

        return Timeline(entries: entries, policy: .after(Date.now.addingTimeInterval(60*15)))
    }
}

/*
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}
 */

struct MarketContract: Identifiable {
    let id: Int
    let name: String
    let cents: Int?
}

// TODO: -- define necessary fields
struct MarketEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let name: String
    let contracts: [MarketContract]
}

struct PredictionMarketWidgetEntryView : View {
    var entry: Provider.Entry
    
    /*
    let marketEntry = MarketEntry(
        date: Date.now,
        configuration: .smiley,
        name: "Democratic 2024 presidential nominee?",  // Shortnmae
        contracts: [
            MarketContract(id: 0, name: "Trump", cents: 64),
            MarketContract(id: 1, name: "Biden", cents: 33),
        ])
     */
    
    var contracts: [MarketContract] {
        Array(entry.contracts.sorted(by: { ($0.cents ?? 0) > ($1.cents ?? 0) }).prefix(3))
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.name)
                .lineLimit(2)
                .truncationMode(.tail)
                .font(.caption)
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
        name: "Democratic 2024 presidential nominee?",  // Shortnmae
        contracts: [
            MarketContract(id: 0, name: "Trump", cents: 64),
            MarketContract(id: 1, name: "Biden", cents: 33),
        ])
}

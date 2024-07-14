//
//  PredictionMarketWidget.swift
//  PredictionMarketWidget
//
//  Created by Collin Palmer on 7/6/24.
//

import WidgetKit
import SwiftUI
import SwiftData

struct PredictionMarketWidget: Widget {
    let kind: String = "PredictionMarketWidget"
    let context = ModelContext(try! ModelContainer(for: PreviousMarketDataModel.self, ContractEntryModel.self, MarketEntryModel.self, configurations: ModelConfiguration()))
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider(modelContext: context)) { entry in
            PredictionMarketWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .environment(\.modelContext, context)
        }
        .supportedFamilies([.systemSmall])
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

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

    private func widgetURL(_ entry: MarketEntry) -> URL {
        let url = URL(string: "\(widgetURLScheme)://")!
        let marketOverviewURL = url.appending(path: "/all")
        
        switch entry.type {
        case .market(let market):
            if let marketId = market?.id {
                return url.appending(path: "/market/\(marketId)")
            } else {
                return marketOverviewURL
            }
        case .error:
            return marketOverviewURL
        }
    }

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            PredictionMarketWidgetEntryView(entry: entry)
                .widgetURL(widgetURL(entry))
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall])
    }
}

#Preview("Single-contract market", as: .systemSmall) {
    PredictionMarketWidget()
} timeline: {
    let singleMarketData = NSDataAsset(preview: .json7419SingleContract).data
    let singleMarketJSON: PIJSONMarket = try! JSONDecoder().decode(PIJSONMarket.self, from: singleMarketData)
    let singleEntry = MarketEntry(date: .now, type: .market(singleMarketJSON.market))
    
    return [singleEntry]
}

#Preview("Live market", as: .systemSmall) {
    PredictionMarketWidget()
} timeline: {
    let liveMarketData = NSDataAsset(preview: .json7057).data
    let liveMarketJSON: PIJSONMarket = try! JSONDecoder().decode(PIJSONMarket.self, from: liveMarketData)
    let liveEntry = MarketEntry(date: .now, type: .market(liveMarketJSON.market))
    
    // TODO: Date for transition to archived?
    
    return [liveEntry]
}

#Preview("Archived market", as: .systemSmall) {
    PredictionMarketWidget()
} timeline: {
    let archivedMarketData = NSDataAsset(preview: .json8069Archived).data
    let archivedMarketJSON: PIJSONMarket = try! JSONDecoder().decode(PIJSONMarket.self, from: archivedMarketData)
    let archivedEntry = MarketEntry(date: .now, type: .market(archivedMarketJSON.market))
    
    return [archivedEntry]
}

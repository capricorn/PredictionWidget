//
//  MarketLiveView.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/23/24.
//

import SwiftUI

struct PredictionMarketWidgetEntryView: View {
    var entry: MarketEntry
    
    var currentEntry: Market? {
        switch entry.type {
        case .market(let market):
            return market
        default:
            return nil
        }
    }
    
    var contracts: [MarketContract] {
        guard let currentEntry else {
            return []
        }
        
        return Array(currentEntry
            .contracts
            .sorted(by: { ($0.cents ?? 0) > ($1.cents ?? 0) })
            .prefix(3))
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
                    if market.archived {
                        MarketArchivedView(market: market)
                    } else {
                        Text(market.name)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .font(.caption.bold())
                            .padding(.bottom, 8)
                        ForEach(contracts) { contract in
                            HStack {
                                Text(contract.name.uppercased())
                                    .font(.caption.smallCaps())
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .padding(.bottom, 2)
                                Spacer()
                                PriceValueView(price: contract.cents!, change: contract.change)
                            }
                            .font(.caption)
                        }
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

#Preview {
    let marketData = NSDataAsset(preview: .json8069Archived).data
    let marketJSON: PIJSONMarket = try! JSONDecoder().decode(PIJSONMarket.self, from: marketData)
    
    let entry = MarketEntry(date: .now, type: .market(marketJSON.market))
    return PredictionMarketWidgetEntryView(entry: entry)
        .widgetPreview()
}

#Preview("Single-contract market") {
    let marketData = NSDataAsset(preview: .json7419SingleContract).data
    let marketJSON: PIJSONMarket = try! JSONDecoder().decode(PIJSONMarket.self, from: marketData)
    
    let entry = MarketEntry(date: .now, type: .market(marketJSON.market))
    return PredictionMarketWidgetEntryView(entry: entry)
        .widgetPreview()
}

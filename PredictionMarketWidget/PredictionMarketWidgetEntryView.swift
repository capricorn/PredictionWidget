//
//  PredictionMarketWidgetEntryView.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/10/24.
//

import Foundation
import SwiftUI
import SwiftData
import WidgetKit

import PredictionMarketWidgetExtension

struct MarketContract: Identifiable {
    let id: Int
    let name: String
    let cents: Int?
    let change: Int?
}

struct Market: Identifiable {
    let id: Int
    let name: String
    let contracts: [MarketContract]
    var archived: Bool = false
}

enum EntryType {
    /// `nil` if no market is selected.
    case market(Market?)
    case error
}

// TODO: -- define necessary fields
struct MarketEntry: TimelineEntry {
    let date: Date
    //let configuration: ConfigurationAppIntent
    let type: EntryType
}

struct PredictionMarketWidgetEntryView : View {
    @Environment(\.modelContext) var modelContext
    
    var currentEntry: Market? {
        switch entry.type {
        case .market(let market):
            return market
        default:
            return nil
        }
    }

    var entry: MarketEntry
    
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
                                    .font(.caption2.smallCaps())
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .padding(.bottom, 2)
                                Spacer()
                                PriceValueView(price: contract.cents!, change: contract.change)
                            }
                            .font(.caption2)
                        }
                        Spacer()
                        refreshTimestamp
                    }
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
    let container = try! ModelContainer(for: PreviousMarketDataModel.self, ContractEntryModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)
    let marketId = 0
    
    let entry1 = PreviousMarketDataModel(marketId: marketId, name: "2024 President", refreshDate: .now, entryType: .current)
    entry1.contracts = [
        .init(id: 1, price: 50, name: "Biden", market: entry1),
        .init(id: 2, price: 36, name: "Trump", market: entry1),
    ]
    context.insert(entry1)
    
    let entry2 = PreviousMarketDataModel(marketId: marketId, name: "2024 President", refreshDate: .now, entryType: .current)
    entry2.contracts = [
        .init(id: 1, price: 50, name: "Biden", market: entry2),
        .init(id: 2, price: 36, name: "Trump", market: entry2),
    ]
    
    context.insert(entry2)

    return PredictionMarketWidgetEntryView(entry: MarketEntry(
        date: Date.now,
        type: .market(Market(
            id: marketId,
            name: "Democratic 2024 presidential nominee?",  // Shortnmae
            contracts: [
                MarketContract(id: 0, name: "Trump", cents: 64, change: nil),
                MarketContract(id: 1, name: "Biden", cents: 33, change: 8),
                MarketContract(id: 1, name: "Jeb", cents: 33, change: -4),
            ]))))
    .environment(\.modelContext, context)
    .previewContext(WidgetPreviewContext(family: .systemSmall))
}

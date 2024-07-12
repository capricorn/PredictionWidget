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

// TODO: Implement queries for curr/prev price
// curr is necessary for displaying anything at this point -- so adjust state machine as necessary..?
struct PredictionMarketWidgetEntryView : View {
    @Environment(\.modelContext) var modelContext
    // TODO: Remove enum usage -- apparently not supported by swiftdata atm
    static let currentType = PreviousMarketDataModel.EntryType.current.rawValue
    static let previousType = PreviousMarketDataModel.EntryType.previous.rawValue

    // TODO: Setup in init instead
    @Query(FetchDescriptor(predicate: #Predicate<PreviousMarketDataModel> { model in model.entryType == currentType })) var currentMarketEntryQuery: [PreviousMarketDataModel]
    /*
    @Query var currentMarketEntryQuery: [PreviousMarketDataModel]
    @Query var previousMarketEntryQuery: [PreviousMarketDataModel]
     */
    @Query(FetchDescriptor(predicate: #Predicate<PreviousMarketDataModel> { model in model.entryType == previousType })) var previousMarketEntryQuery: [PreviousMarketDataModel]
    
    var currentEntry: PreviousMarketDataModel? {
        currentMarketEntryQuery.first
    }
    
    var previousEntry: PreviousMarketDataModel? {
        previousMarketEntryQuery.first
    }

    var entry: MarketEntry //Provider.Entry
    
    var cacheState: PreviousMarketDataModel.CacheState {
        switch entry.type {
        case .market(let market):
            if let market {
                return try! PreviousMarketDataModel.cacheState(selectedMarketId: market.id, context: modelContext)
            } else {
                return .empty
            }
        default:
            return .empty
        }
    }
    
    
    // TODO: Relying on cache state is one thing -- should it also take timeline state into account..?
    var contracts: [MarketContract] {
        let c: [MarketContract] = switch cacheState {
        case .empty:
            []
        case .currentSet(let previousMarketDataModel):
            previousMarketDataModel.contracts.map {
                MarketContract(id: $0.id, name: $0.name, cents: $0.price, change: nil)
            }
        case .currentAndPreviousSet(let current, let previous):
            zip(current.contracts.sorted(by: { $0.id < $1.id }), previous.contracts.sorted(by: { $0.id < $1.id })).map {
                let change = $0.price - $1.price
                return MarketContract(id: $0.id, name: $0.name, cents: $0.price, change: (change == 0) ? nil : change)
            }
        }
        
        return Array(c
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
    
    let entry1 = PreviousMarketDataModel(marketId: marketId, refreshDate: .now, entryType: .current)
    entry1.contracts = [
        .init(id: 1, price: 50, name: "Biden", market: entry1),
        .init(id: 2, price: 36, name: "Trump", market: entry1),
    ]
    context.insert(entry1)
    
    let entry2 = PreviousMarketDataModel(marketId: marketId, refreshDate: .now, entryType: .current)
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

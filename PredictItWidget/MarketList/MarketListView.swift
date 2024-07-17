//
//  MarketListView.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/5/24.
//

import SwiftUI
import WidgetKit

struct MarketListView: View {
    enum ViewState {
        case loading
        case ready
        case refreshError
    }
    
    @Environment(\.modelContext) var modelContext
    @State private var markets: [PIJSONMarket] = []
    @State private var viewState: ViewState = .loading
    @AppStorage(PredictionWidgetUserDefaultsKeys.widgetMarket.rawValue, store: .predictionWidget) var selectedMarketId: Int?
    
    private func refreshMarkets() async {
        do {
            let data = try await PredictItAPI.fetchMarketData()
            
            try modelContext.delete(model: MarketEntryModel.self)
            
            for market in data {
                let entry = MarketEntryModel(id: market.id, name: market.shortName)
                modelContext.insert(entry)
            }
            
            await MainActor.run {
                markets = data
                viewState = .ready
            }
        } catch {
            print("Failed to fetch market data: \(error)")
            viewState = .refreshError
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            switch viewState {
            case .loading:
                ProgressView()
            case .ready:
                Text("\(markets.count) Market\(markets.count == 1 ? "" : "s")")
                .font(.title.weight(.light))
                .padding()
                ScrollViewReader { reader in
                    List(markets) { market in
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    if market.id == selectedMarketId {
                                        Text("\(Image(systemName: "star"))\(market.name)")
                                    } else {
                                        Text(market.name)
                                            .padding()
                                    }
                                }
                                MarketContractListView(contracts: market.contracts)
                                    .padding()
                            }
                            VStack {
                                Image(systemName: "link")
                                    .padding(.top, 8)
                                    .onTapGesture {
                                        UIApplication.shared.open(market.marketURL)
                                    }
                                Spacer()
                            }
                        }
                        .id(market.id)
                        .onTapGesture {
                            Task {
                                // TODO: Guarantee of all of this in a transaction..? (Worried about bad state)
                                await MainActor.run {
                                    if (UserDefaults.predictionWidget.value(.widgetMarket) as? Int) == market.id {
                                        UserDefaults.predictionWidget.set(.widgetMarket(marketId: nil))
                                    } else {
                                        UserDefaults.predictionWidget.set(.widgetMarket(marketId: market.id))
                                    }
                                }
                                
                                do {
                                    try await CacheActor.shared.clearCache()
                                } catch {
                                    print("Failed to clear cache: \(error)")
                                }
                                
                                await MainActor.run {
                                    WidgetCenter.shared.reloadTimelines(ofKind: "PredictionMarketWidget")
                                }
                                // TODO: Shared identifier
                            }
                        }
                        // TODO: Iterate contract list in separate view
                    }
                }
                .refreshable {
                    await refreshMarkets()
                }
            case .refreshError:
                List {
                    Text("Failed to refresh markets. Try again.")
                }
                .refreshable {
                    await refreshMarkets()
                }
            }
        }
        .task {
            await refreshMarkets()
        }
    }
}

#Preview {
    MarketListView()
}

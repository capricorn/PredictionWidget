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
    
    @State private var markets: [PIJSONMarket] = []
    @State private var viewState: ViewState = .loading
    @AppStorage(PredictionWidgetUserDefaultsKeys.widgetMarket.rawValue, store: .predictionWidget) var selectedMarketId: Int?
    
    private func refreshMarkets() async {
        do {
            let data = try await PredictItAPI.fetchMarketData()
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
                List(markets) { market in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(market.name)
                                .padding()
                            if market.id == selectedMarketId {
                                Spacer()
                                Image(systemName: "star")
                            }
                        }
                        MarketContractListView(contracts: market.contracts)
                            .padding()
                    }
                    .onTapGesture {
                        if (UserDefaults.predictionWidget.value(.widgetMarket) as? Int) == market.id {
                            UserDefaults.predictionWidget.set(.widgetMarket(marketId: nil))
                        } else {
                            UserDefaults.predictionWidget.set(.widgetMarket(marketId: market.id))
                        }
                        // TODO: Shared identifier
                        WidgetCenter.shared.reloadTimelines(ofKind: "PredictionMarketWidget")
                    }
                    // TODO: Iterate contract list in separate view
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

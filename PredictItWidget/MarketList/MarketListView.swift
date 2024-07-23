//
//  MarketListView.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/5/24.
//

import SwiftUI
import WidgetKit
import SwiftData

struct MarketListView: View {
    enum ViewState {
        case loading
        case ready(refreshDate: Date)
        case refreshError
    }
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.predictItAPI) var predictItAPI
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var markets: [PIJSONMarket] = []
    @State private var viewState: ViewState = .loading
    
    private func refreshMarkets() async {
        do {
            let data = try await predictItAPI.fetchMarketData()
            
            try modelContext.delete(model: MarketEntryModel.self)
            
            for market in data {
                let m = market.market
                let entry = MarketEntryModel(id: m.id, name: m.name)
                modelContext.insert(entry)
            }
            
            await MainActor.run {
                markets = data
                viewState = .ready(refreshDate: .now)
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
            case .ready(let refreshDate):
                VStack(alignment: .leading) {
                    Text("\(markets.count) Market\(markets.count == 1 ? "" : "s")")
                        .font(.title.weight(.light))
                    Text("Updated \(refreshDate.formatted())")
                        .font(.caption.weight(.light))
                }
                .padding(.horizontal)
                ScrollViewReader { reader in
                    List(markets) { market in
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                Text(market.name)
                                    .font(.body.bold())
                                    .padding(.trailing, 16)
                                Spacer()
                                Image(systemName: "link")
                                    .onTapGesture {
                                        UIApplication.shared.open(market.marketURL)
                                    }
                            }
                            .padding([.vertical,.bottom], 8)
                            MarketContractListView(contracts: market.contracts)
                                .padding(.bottom, 8)
                        }
                        .id(market.id)
                    }
                    .onReceive(appViewModel.openURLPublisher) { url in
                        if let marketId = Int(url.lastPathComponent) {
                            reader.scrollTo(marketId)
                        }
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
    // TODO: If you want to preview this view easily, have to inject API (imo inject via environment key)
    let container = try! ModelContainer(for: ContractEntryModel.self, MarketEntryModel.self, configurations: ModelConfiguration())
    let context = ModelContext(container)
    return MarketListView()
        .environment(\.modelContext, context)
        .environment(\.predictItAPI, MockFetchAllMarketData())
        .environmentObject(AppViewModel())
}

//
//  MarketListView.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/5/24.
//

import SwiftUI

struct MarketListView: View {
    @State private var markets: [PIMarketData] = []
    
    // TODO: Handle fetch error state
    
    private func refreshMarkets() async {
        do {
            let data = try await PredictItAPI.fetchMarketData()
            await MainActor.run {
                markets = data
            }
        } catch {
            print("Failed to fetch market data: \(error)")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(markets.count) Market\(markets.count == 1 ? "" : "s")")
                .font(.title.weight(.light))
                .padding()
            List(markets) { market in
                Text(market.name)
                    .padding()
            }
            .refreshable {
                await refreshMarkets()
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

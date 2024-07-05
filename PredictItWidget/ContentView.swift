//
//  ContentView.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/4/24.
//

import SwiftUI

struct ContentView: View {
    @State private var marketName: String?
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            if let marketName {
                Text(marketName)
            }
        }
        .padding()
        .task {
            do {
                let marketData = try await PredictItAPI.fetchMarketData(marketId: "7057")
                await MainActor.run {
                    self.marketName = marketData.name
                }
            } catch {
                print("Failed to fetch market data: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}

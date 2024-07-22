//
//  MarketContractListView.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/5/24.
//

import SwiftUI

struct MarketContractListView: View {
    let contracts: [PIJSONMarketContract]
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(contracts) { contract in
                HStack {
                    Text(contract.name)
                        .lineLimit(1)
                        .font(.body.smallCaps().weight(.light))
                        .truncationMode(.tail)
                    Spacer()
                    if let lastTradePrice = contract.lastTradePrice {
                        Text("\(lastTradePrice)¢")
                            .monospaced()
                    } else {
                        Text("--¢")
                            .monospaced()
                    }
                }
            }
        }
    }
}

#Preview {
    let marketData = NSDataAsset(preview: .json8069Archived).data
    let marketJSON: PIJSONMarket = try! JSONDecoder().decode(PIJSONMarket.self, from: marketData)
    
    return MarketContractListView(contracts: marketJSON.contracts)
}

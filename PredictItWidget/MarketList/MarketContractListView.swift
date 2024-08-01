//
//  MarketContractListView.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/5/24.
//

import SwiftUI

struct MarketContractListView: View {
    let contracts: [PIJSONMarketContract]
    
    var enumeratedContracts: [(Int,PIJSONMarketContract)] {
        contracts
            .enumerated()
            .map { ($0.offset, $0.element) }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(enumeratedContracts, id: \.0) { index, contract in
                HStack {
                    Text((contracts.count == 1) ? "YES" : contract.name)
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
                .background {
                    (index % 2 == 0) ? Color.clear : Color.gray.opacity(0.1)
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

#Preview("Single contract market") {
    let marketData = NSDataAsset(preview: .json7419SingleContract).data
    let marketJSON: PIJSONMarket = try! JSONDecoder().decode(PIJSONMarket.self, from: marketData)
    
    return MarketContractListView(contracts: marketJSON.contracts)
}

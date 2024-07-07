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

// TODO: Load from xml
/*
 #Preview {
 MarketContractListView(contract: <#T##PIMarketContract#>)
 }
 */

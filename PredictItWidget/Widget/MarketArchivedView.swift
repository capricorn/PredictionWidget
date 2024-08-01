//
//  MarketArchivedView.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/18/24.
//

import SwiftUI

struct MarketArchivedView: View {
    let market: Market
    
    private var contracts: [MarketContract] {
        Array(market.contracts.prefix(3))
    }
    
    private var winningContract: MarketContract? {
        market.contracts.sorted(by: { ($0.cents ?? 0) > ($1.cents ?? 0) }).first
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(market.name)
                .lineLimit(2)
                .truncationMode(.tail)
                .padding(.bottom, 8)
            ForEach(contracts) { contract in
                HStack {
                    if let winningContract, contract.id == winningContract.id {
                        Text("\(contract.name.uppercased())")
                            .font(.caption.smallCaps().bold())
                            .lineLimit(1)
                        Spacer()
                        Text("✓")
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                        // TODO: How to resize to fit same space as font?
                        //Image(systemName: "checkmark.square")
                    } else {
                        Text("\(contract.name.uppercased())")
                            .font(.caption.smallCaps())
                            .lineLimit(1)
                            .opacity(0.5)
                    }
                }
            }
            Spacer()
        }
        .dynamicTypeSize(.large)
    }
}

#Preview {
    let marketData = NSDataAsset(preview: .json8069Archived).data
    let marketJSON: PIJSONMarket = try! JSONDecoder().decode(PIJSONMarket.self, from: marketData)
    
    return TimestampContainerView(entry: MarketEntry(date: .now, type: .market(nil))) {
        MarketArchivedView(market: marketJSON.market)
    }
    .widgetPreview()
}

#Preview("Single-contract market") {
    let marketData = NSDataAsset(preview: .json7419SingleContract).data
    let marketJSON: PIJSONMarket = try! JSONDecoder().decode(PIJSONMarket.self, from: marketData)
    
    return TimestampContainerView(entry: MarketEntry(date: .now, type: .market(nil))) {
        MarketArchivedView(market: marketJSON.market)
    }
    .widgetPreview()   
}

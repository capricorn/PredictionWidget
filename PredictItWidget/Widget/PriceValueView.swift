//
//  PriceValueView.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/10/24.
//

import SwiftUI

struct PriceValueView: View {
    let price: Int
    // TODO: Handle when change is zero? (Always nil in that case?)
    let change: Int?
    
    var changeSign: String? {
        guard let change else {
            return nil
        }
        
        return (change > 0) ? "+" : ""
    }
    
    var changeColor: Color? {
        guard let change else {
            return nil
        }
        
        return (change > 0) ? .green : .red
    }
    
    var priceLabel: String {
        (price < 10) ? " \(price)¢" : "\(price)¢"
    }
    
    var changePricePadding: String {
        guard let change else {
            return "    "
        }
        
        return (abs(change) > 9) ? " " : "  "
    }
    
    var body: some View {
        if let change {
            // TODO: Padding price <10
            Group {
                Text("\(changeSign!)\(change)")
                    .foregroundStyle(changeColor!) +
                Text(changePricePadding) +
                Text(priceLabel)
            }
            .monospaced()
        } else {
            Text("\(changePricePadding)\(priceLabel)")
                .monospaced()
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        // TODO: Change nil should just take up empty space
        PriceValueView(price: 8, change: nil)
        PriceValueView(price: 54, change: nil)
        PriceValueView(price: 54, change: -3)
        PriceValueView(price: 54, change: 7)
        PriceValueView(price: 9, change: 7)
        PriceValueView(price: 9, change: 32)
    }
}

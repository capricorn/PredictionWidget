//
//  PriceValueView.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/10/24.
//

import SwiftUI

struct PriceValueView: View {
    // TODO: Switch on these three states
    enum PriceSign {
        case positive
        case negative
        
        var prefix: String {
            switch self {
            case .positive:
                "+"
            case .negative:
                ""
            }
        }
        
        var changeArrow: Text {
            switch self {
            case .positive:
                Text("↑")
            case .negative:
                Text("↓")
            }
        }
        
        var color: Color {
            switch self {
            case .positive:
                .green
            case .negative:
                .red
            }
        }
    }
    
    var changeSign: PriceSign {
        // Don't care case
        guard let change else {
            return .positive
        }
        
        return (change >= 0) ? .positive : .negative
    }
    
    var changeExists: Bool {
        guard let change else {
            return false
        }
        
        return change != 0
    }
    
    var twoDigitChange: Bool {
        guard let change else {
            return false
        }
        
        return abs(change) > 9
    }
    
    var twoDigitPrice: Bool {
        abs(price) >= 10
    }
    
    let price: Int
    // TODO: Handle when change is zero? (Always nil in that case?)
    let change: Int?
    
    var changeColor: Color? {
        guard let change else {
            return nil
        }
        
        return (change > 0) ? .green : .red
    }
    
    var priceLabel: String {
        "\(price)¢"
    }
    
    // TODO: Subviews for these (less repetition..?) Want to keep state machine..
    var body: some View {
        switch (change: changeExists, changeSign: changeSign, twoDigitChange: twoDigitChange, twoDigitPrice: twoDigitPrice) {
        case (change: false,_,_,twoDigitPrice: true):
            Text("    \(priceLabel)")
                .monospaced()
        case (change: false,_,_,twoDigitPrice: false):
            Text("     \(priceLabel)")
                .monospaced()
        case (change: true, _, twoDigitChange: false, twoDigitPrice: false):
            Text(" \(changeSign.changeArrow)\(abs(change!))")
                .foregroundStyle(changeSign.color)
                .monospaced()
            + Text("  \(priceLabel)")
                .monospaced()
        case (change: true, _, twoDigitChange: true, twoDigitPrice: false):
            Text("\(changeSign.changeArrow)\(abs(change!))")
                .foregroundStyle(changeSign.color)
                .monospaced()
            + Text("  \(priceLabel)")
                .monospaced()
        case (change: true, _, twoDigitChange: false, twoDigitPrice: true):
            Text(" \(changeSign.changeArrow)\(abs(change!))")
                .foregroundStyle(changeSign.color)
                .monospaced()
            + Text(" \(priceLabel)")
                .monospaced()
        case (change: true, _, twoDigitChange: true, twoDigitPrice: true):
            Text("\(changeSign.changeArrow)\(abs(change!))")
                .foregroundStyle(changeSign.color)
                .monospaced()
            + Text(" \(priceLabel)")
                .monospaced()
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        // TODO: Implement switch that covers all preview cases
        PriceValueView(price: 8, change: nil)
        PriceValueView(price: 54, change: nil)
        PriceValueView(price: 54, change: -3)
        PriceValueView(price: 54, change: 7)
        PriceValueView(price: 9, change: 7)
        PriceValueView(price: 91, change: 16)
        PriceValueView(price: 9, change: 32)
        PriceValueView(price: 9, change: -3)
    }
}

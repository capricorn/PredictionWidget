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
        MarketListView()
    }
}

#Preview {
    ContentView()
}

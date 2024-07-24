//
//  ContentView.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/4/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var marketName: String?
    let modelContext = ModelContext(try! ModelContainer(for: appSchema, configurations: ModelConfiguration()))
    
    var body: some View {
        MarketListView()
            .environment(\.modelContext, modelContext)
    }
}

#Preview {
    ContentView()
}

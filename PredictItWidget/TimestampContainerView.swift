//
//  TimestampContainerView.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/8/24.
//

import SwiftUI
import WidgetKit

struct TimestampContainerView<Content: View>: View {
    let entry: MarketEntry
    let builder: () -> Content
    
    var refreshTimestamp: some View {
        Text("\(Image(systemName: "clock.arrow.2.circlepath")) \(entry.date.formatted())")
            .font(.system(size: 8).weight(.light))
    }
    
    init(entry: MarketEntry, builder: @escaping () -> Content) {
        self.entry = entry
        self.builder = builder
    }
    
    var body: some View {
        ZStack {
            HStack {
                builder()
                Spacer()
            }
            VStack {
                Spacer()
                HStack {
                    refreshTimestamp
                    Spacer()
                    LogoView()
                        .sizeToTextHeight(Text("").font(.system(size: 8)))
                }
            }
        }
    }
}

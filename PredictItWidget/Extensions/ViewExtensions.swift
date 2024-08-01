//
//  ViewExtensions.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/18/24.
//

import Foundation
import SwiftUI

private struct InlineTextLabel<Content: View>: View {
    @State private var textSize: CGSize?
    
    let text: () -> Text
    let content: () -> Content
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if let textSize {
                content()
                    .frame(height: textSize.height)
            }
            
            // TODO: Ignore sizing in actual view hierarchy..? (Compute dimensions but don't add..)
            text()
                .overlay {
                    GeometryReader { reader in
                        Color.clear
                        .onAppear {
                            self.textSize = reader.size
                        }
                    }
                }
        }
    }
}

extension View {
    func widgetPreview() -> some View {
       self
        .padding()
        .frame(width: 170, height: 170)
        .overlay {
            RoundedRectangle(cornerRadius: 25.0)
                .stroke(.black.opacity(0.2))
                .shadow(radius: 10)
        }
    }
    
    func sizeToTextHeight(_ text: Text) -> some View {
        InlineTextLabel(text: { text }, content: {
            self
        })
    }
}

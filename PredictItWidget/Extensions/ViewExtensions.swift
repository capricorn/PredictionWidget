//
//  ViewExtensions.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/18/24.
//

import Foundation
import SwiftUI

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
}

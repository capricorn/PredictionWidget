//
//  LogoView.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 8/1/24.
//

import SwiftUI

struct LogoView: View {
    func circle(_ reader: GeometryProxy) -> some View {
        Circle()
            .fill(.purple)
            .frame(width: side(reader)/8, height: side(reader)/8)
    }
    
    func side(_ reader: GeometryProxy) -> CGFloat {
        reader.size.width
    }
    
    func padding(_ reader: GeometryProxy) -> CGFloat {
        side(reader) * (3/8)
    }
    
    var body: some View {
        ZStack {
            GeometryReader { reader in
                circle(reader)
                    .position(x: side(reader)/2, y: padding(reader))
                circle(reader)
                    .position(x: padding(reader), y: side(reader)-padding(reader))
                circle(reader)
                    .position(x: side(reader)-padding(reader), y: side(reader)-padding(reader))
            }
        }
        //.background(.white)
        .aspectRatio(1.0, contentMode: .fit)
    }
}


#Preview {
    LogoView()
        .frame(width: 100, height: 100)
}

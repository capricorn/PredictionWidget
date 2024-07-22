//
//  PredictItAPIRepresentable.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/22/24.
//

import Foundation
import SwiftUI

protocol PredictItAPIRepresentable {
    func fetchMarketData(marketId: String, result: @escaping (PIJSONMarket?) -> Void) throws
    func fetchMarketData() async throws -> [PIJSONMarket]
}

private struct PredictItAPIEnvironmentKey: EnvironmentKey {
    static var defaultValue: PredictItAPIRepresentable = PredictItAPI()
}

extension EnvironmentValues {
    var predictItAPI: PredictItAPIRepresentable {
        get {
            self[PredictItAPIEnvironmentKey.self]
        }
        set {
            self[PredictItAPIEnvironmentKey.self] = newValue
        }
    }
}

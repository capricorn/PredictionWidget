//
//  MockFetchAllMarketData.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/22/24.
//

import Foundation
import SwiftUI

struct MockFetchAllMarketData: PredictItAPIRepresentable {
    func fetchMarketData(marketId: String, result: @escaping (PIJSONMarket?) -> Void) throws {
        result(nil)
    }
    
    func fetchMarketData() async throws -> [PIJSONMarket] {
        let marketData = NSDataAsset(preview: .jsonAll).data
        let markets = try JSONDecoder().decode(PIJSONAllMarkets.self, from: marketData)
        
        return markets.markets
    }
}

struct MockFetchError: PredictItAPIRepresentable {
    func fetchMarketData(marketId: String, result: @escaping (PIJSONMarket?) -> Void) throws {
        throw URLError(.badServerResponse)
    }
    
    func fetchMarketData() async throws -> [PIJSONMarket] {
        throw URLError(.badServerResponse)
    }
}

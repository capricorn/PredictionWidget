//
//  PredictItAPI.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/4/24.
//

import Foundation
import XMLCoder

enum PredictItAPI {
    static let apiBasePath = URL(string: "https://www.predictit.org/api")!

    static func fetchMarketData(marketId: String) async throws -> PIMarketData {
        let req = URLRequest(url: apiBasePath.appending(path: "marketdata/markets/\(marketId)"))
        let (data, resp) = try await URLSession.shared.data(for: req)
        
        // TODO: Handle status codes? (Anything non-200)
        // TODO: Handle API errors..?
        
        return try XMLDecoder().decode(PIMarketData.self, from: data)
    }
}

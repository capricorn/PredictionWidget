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
        var req = URLRequest(url: apiBasePath.appending(path: "/marketdata/markets/\(marketId)"))
        // TODO: Switch over to json (May as well keep the xml encoding version)
        req.setValue("application/xml", forHTTPHeaderField: "Accept")
        let (data, _) = try await URLSession.shared.data(for: req)
        
        // TODO: Handle status codes? (Anything non-200)
        // TODO: Handle API errors..?
        
        return try XMLDecoder().decode(PIMarketData.self, from: data)
    }
    
    /// Fetch data from all markets
    static func fetchMarketData() async throws -> [PIMarketData] {
        var req = URLRequest(url: apiBasePath.appending(path: "/marketdata/all"))
        // TODO: Switch over to json (May as well keep the xml encoding version)
        req.setValue("application/xml", forHTTPHeaderField: "Accept")
        let (data, _) = try await URLSession.shared.data(for: req)
        
        // TODO: Handle status codes? (Anything non-200)
        // TODO: Handle API errors..?
        
        let marketList = try XMLDecoder().decode(PIMarketList.self, from: data)
        return marketList.markets.marketData
    }
}

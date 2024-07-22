//
//  PredictItAPI.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/4/24.
//

import Foundation

struct PredictItAPI: PredictItAPIRepresentable {
    static let apiBasePath = URL(string: "https://www.predictit.org/api")!

    static func fetchMarketData(marketId: String) async throws -> PIJSONMarket {
        var req = URLRequest(url: apiBasePath.appending(path: "/marketdata/markets/\(marketId)"))
        // TODO: Switch over to json (May as well keep the xml encoding version)
        //req.setValue("application/xml", forHTTPHeaderField: "Accept")
        let (data, _) = try await URLSession.shared.data(for: req)
        
        // TODO: Handle status codes? (Anything non-200)
        // TODO: Handle API errors..?
        
        return try JSONDecoder().decode(PIJSONMarket.self, from: data)
    }
    
    func fetchMarketData(marketId: String, result: @escaping (PIJSONMarket?) -> Void) throws {
        var req = URLRequest(url: PredictItAPI.apiBasePath.appending(path: "/marketdata/markets/\(marketId)"))
        let task = URLSession.shared.dataTask(with: req) { (data: Data?, resp: URLResponse?, error: Error?) in
            guard let data else {
                result(nil)
                return
            }
            
            if let error {
                result(nil)
            }
            
            if let resp, (resp as? HTTPURLResponse)?.statusCode != 200 {
                result(nil)
            }
            
            let market = try? JSONDecoder().decode(PIJSONMarket.self, from: data)
            result(market)
        }
        task.resume()
    }
    
    /// Fetch data from all markets
    func fetchMarketData() async throws -> [PIJSONMarket] {
        var req = URLRequest(url: PredictItAPI.apiBasePath.appending(path: "/marketdata/all"))
        // TODO: Switch over to json (May as well keep the xml encoding version)
        //req.setValue("application/xml", forHTTPHeaderField: "Accept")
        let (data, _) = try await URLSession.shared.data(for: req)
        
        // TODO: Handle status codes? (Anything non-200)
        // TODO: Handle API errors..?
        
        let marketList = try JSONDecoder().decode(PIJSONAllMarkets.self, from: data)
        return marketList.markets
    }
}

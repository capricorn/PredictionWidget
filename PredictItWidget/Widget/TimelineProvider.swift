//
//  TimelineProvider.swift
//  PredictionMarketWidgetExtension
//
//  Created by Collin Palmer on 7/14/24.
//

import Foundation
import WidgetKit
import SwiftUI
import SwiftData

private extension URLSession {
    // TODO: Any way to just wrap a callback generically with this?
    func syncDataTask(with req: URLRequest) -> (Data?, URLResponse?, Error?) {
        let group = DispatchGroup()
        var data: Data? = nil
        var resp: URLResponse? = nil
        var error: Error? = nil
        
        group.enter()
        let task = URLSession.shared.dataTask(with: req) { (d, r, e) in
            data = d
            resp = r
            error = e
            group.leave()
        }
        task.resume()
        // TODO: Consider timeout w/ exception?
        group.wait()
        return (data, resp, error)
    }
}

private extension PredictItAPI {
    static func syncFetchMarketData(marketId: Int) throws -> PIJSONMarket {
        let req = URLRequest(url: PredictItAPI.apiBasePath.appending(path: "/marketdata/markets/\(marketId)"))
        let (data,resp,error) = URLSession.shared.syncDataTask(with: req)
        
        if let error {
            throw error
        }
        
        if let httpResp = resp as? HTTPURLResponse, httpResp.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        
        guard let data else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(PIJSONMarket.self, from: data)
    }
}

struct Provider: AppIntentTimelineProvider {
    typealias MarketDataFetcher = (Int) throws -> PIJSONMarket
    
    static let queue = DispatchQueue(label: "PredictionWidgetQueue")
    static let group = DispatchGroup()
    static let cache = WidgetCache()
    
    func placeholder(in context: Context) -> MarketEntry {
        let marketData = NSDataAsset(preview: .json8069Archived).data
        let marketJSON: PIJSONMarket = try! JSONDecoder().decode(PIJSONMarket.self, from: marketData)
        
        return MarketEntry(date: .now, type: .market(marketJSON.market))
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> MarketEntry {
        if context.isPreview {
            return self.placeholder(in: context)
        } else {
            // TODO: Load current widget state
            return MarketEntry(date: Date.now, type: .market(Market(id: 0, name: "Test Market", contracts: [])))
        }
    }
    
    static func getTimelineEntry(
        selectedMarketId: Int?,
        fetcher: MarketDataFetcher = PredictItAPI.syncFetchMarketData,
        cache: WidgetCache = .shared,
        now: Date = .now
    ) -> MarketEntry {
        guard let selectedMarketId else {
            return MarketEntry(date: .now, type: .market(nil))
        }
        
        guard cache.stale(marketId: selectedMarketId, now: now) else {
            let market = cache.market(marketId: selectedMarketId)
            return MarketEntry(date: now, type: .market(market))
        }
        
        // Otherwise, perform a fetch and update the cache
        do {
            let marketData = try fetcher(selectedMarketId)
            // TODO: Consider sane option here?
            try! cache.insert(marketData, now: now)
            
            let market = cache.market(marketId: selectedMarketId)
            return MarketEntry(date: now, type: .market(market))
        } catch {
            let entry = MarketEntry(date: .now, type: .error)
            return entry
        }
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<MarketEntry> {
        return await withUnsafeContinuation { (continuation: UnsafeContinuation<Timeline<MarketEntry>, Never>) in
            Provider.queue.sync {
                Provider.group.enter()
                
                let entry = Provider.getTimelineEntry(selectedMarketId: configuration.selectedMarket?.id)
                continuation.resume(returning: Timeline(entries: [entry], policy: .after(Date.now.addingTimeInterval(60*15))))
                Provider.group.leave()
            }
            
            Provider.group.wait()
        }
    }
}

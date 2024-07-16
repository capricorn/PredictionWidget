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

private extension PIJSONMarketContract {
    var contract: MarketContract {
        MarketContract(id: self.id, name: self.shortName, cents: self.lastTradePrice, change: nil)
    }
}

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
    static func syncFetchMarketData(marketId: Int) -> PIJSONMarket? {
        let req = URLRequest(url: PredictItAPI.apiBasePath.appending(path: "/marketdata/markets/\(marketId)"))
        let (data,_,_) = URLSession.shared.syncDataTask(with: req)
        
        if let data, let market = try? JSONDecoder().decode(PIJSONMarket.self, from: data) {
            return market
        }
        
        return nil
    }
}

struct Provider: AppIntentTimelineProvider {
    let modelContext: ModelContext
    static let queue = DispatchQueue(label: "PredictionWidgetQueue")
    static let group = DispatchGroup()
    static let cache = WidgetCache()
    
    func placeholder(in context: Context) -> MarketEntry {
        MarketEntry(date: Date.now, type: .market(Market(id: 0, name: "Test Market", contracts: [])))
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> MarketEntry {
        MarketEntry(date: Date.now, type: .market(Market(id: 0, name: "Test Market", contracts: [])))
    }
    
    static func getTimelineEntry(selectedMarketId: Int?) -> MarketEntry {
        if let marketId = selectedMarketId {
            if let marketData = PredictItAPI.syncFetchMarketData(marketId: marketId) {
                let entry = MarketEntry(
                date: Date.now,
                type: .market(Market(
                    id: marketData.id,
                    name: marketData.shortName,
                    contracts: marketData.contracts.map({$0.contract}))))
                
                return entry
            } else {
                let entry = MarketEntry(date: .now, type: .error)
                return entry
            }
        } else {
            return MarketEntry(date: .now, type: .market(nil))
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

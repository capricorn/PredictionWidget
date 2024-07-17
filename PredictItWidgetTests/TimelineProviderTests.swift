//
//  TimelineProviderTests.swift
//  PredictItWidgetTests
//
//  Created by Collin Palmer on 7/16/24.
//

import XCTest
import SwiftData
@testable import PredictItWidget

final class TimelineProviderTests: XCTestCase {
    var cache: PredictItWidget.WidgetCache!
    var market: PredictItWidget.PIJSONMarket!

    override func setUpWithError() throws {
        self.cache = WidgetCache(configuration: ModelConfiguration(isStoredInMemoryOnly: true))
        guard let url = Bundle(for: Self.self).url(forResource: "7057", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decodedMarket = try? JSONDecoder().decode(PredictItWidget.PIJSONMarket.self, from: data)
        else {
            XCTFail("Failed to load market json from bundle.")
            return
        }
        
        self.market = decodedMarket
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNoMarketSelected() throws {
        let fetcher: Provider.MarketDataFetcher = { _ in self.market }
        let entry = Provider.getTimelineEntry(
            selectedMarketId: nil,
            fetcher: fetcher,
            cache: cache
        )

        switch entry.type {
        case .market(nil):
            return
        default:
            XCTFail("Unexpected entry type: \(entry.type)")
        }
    }
    
    /// If a market is selected and the fetch fails, return an error.
    func testMarketFetchError() throws {
        let fetcher: Provider.MarketDataFetcher = { _ in throw URLError(.badServerResponse) }
        
        let entry = Provider.getTimelineEntry(
            selectedMarketId: market.id,
            fetcher: fetcher,
            cache: cache
        )
        
        switch entry.type {
        case .error:
            return
        default:
            XCTFail("Unexpected entry type: \(entry.type)")
        }
    }
    
    func testStaleCache() throws {
        let fetcher: Provider.MarketDataFetcher = { _ in self.market }
        let insertDate = Date.now
        
        _ = Provider.getTimelineEntry(
            selectedMarketId: market.id,
            fetcher: fetcher,
            cache: cache,
            now: insertDate
        )
        
        let refreshDate = insertDate.addingTimeInterval(WidgetCache.minimumStaleElapsedTime + 1)
        
        let entry = Provider.getTimelineEntry(
            selectedMarketId: market.id,
            fetcher: fetcher,
            cache: cache,
            now: refreshDate
        )
        
        switch entry.type {
        case .market(let market) where market != nil:
            XCTAssert(market!.name == "Democratic 2024 presidential nominee?", "\(market!.name)")
            return
        default:
            XCTFail("Unexpected entry type: \(entry.type)")
        }
    }
    
    func testFreshCache() throws {
        let fetcher: Provider.MarketDataFetcher = { _ in self.market }
        let insertDate = Date.now
        
        _ = Provider.getTimelineEntry(
            selectedMarketId: market.id,
            fetcher: fetcher,
            cache: cache,
            now: insertDate
        )
        
        let refreshDate = insertDate.addingTimeInterval(WidgetCache.minimumStaleElapsedTime - 1)
        
        let entry = Provider.getTimelineEntry(
            selectedMarketId: market.id,
            fetcher: fetcher,
            cache: cache,
            now: refreshDate
        )
        
        switch entry.type {
        case .market(let market) where market != nil:
            XCTAssert(cache.previousEntry(marketId: market!.id) == nil)
            return
        default:
            XCTFail("Unexpected entry type: \(entry.type)")
        }
    }
    
    func testContractPriceDiff() throws {
        guard let contractIndex = market.contracts.firstIndex(where: {$0.id == 24808}) else {
            XCTFail("Failed to find contract.")
            return
        }
        
        var modifiedContract = market.contracts[contractIndex]
        modifiedContract.lastTradePrice! = 40
        
        var changedMarket = market!
        changedMarket.contracts[contractIndex] = modifiedContract
        
        let firstFetcher: Provider.MarketDataFetcher = { _ in self.market }
        let secondFetcher: Provider.MarketDataFetcher = { _ in changedMarket }
        
        
        let initialRefresh = Date.now
        
        _ = Provider.getTimelineEntry(
            selectedMarketId: market.id,
            fetcher: firstFetcher,
            cache: cache,
            now: initialRefresh
        )
        
        let entry = Provider.getTimelineEntry(
            selectedMarketId: market.id,
            fetcher: secondFetcher,
            cache: cache,
            now: initialRefresh.addingTimeInterval(WidgetCache.minimumStaleElapsedTime + 1)
        )
        
        // WIP: Why is widgetMarket.contracts empty? Maybe something to do with cache deletion?
        // Consider: manual save after transaction..?
        switch entry.type {
        case .market(let widgetMarket):
            let diffContract = widgetMarket!.contracts.first(where: {$0.id == 24808})
            XCTAssert(diffContract?.change == -4)
        default:
            XCTFail("Unexpected entry type: \(entry.type)")
        }
    }
}

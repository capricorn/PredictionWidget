//
//  CacheActorTests.swift
//  PredictItWidgetTests
//
//  Created by Collin Palmer on 7/12/24.
//

import XCTest
import SwiftData
//@testable import PredictionMarketWidgetExtension
@testable import PredictItWidget

final class CacheActorTests: XCTestCase {
    var cache: CacheActor!
    var market: PIJSONMarket!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.cache = CacheActor(configuration: ModelConfiguration(isStoredInMemoryOnly: true))
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

    func testCacheSetCurrent() async throws {
        try await cache.insertCache(marketData: market)
        // TODO: Verify cache state via PreviousMarketDataModel
        // TODO: (IMO, move that to CacheActor instead)
        //switch PreviousMarketDataModel.cacheState(selectedMarketId: marketJson.id, context: cache.mod)
        let state = await cache.state
        switch state {
        case .currentSet(let currentMarket):
            XCTAssert(currentMarket.marketId == market.id)
        default:
            XCTFail("Unexpected state: \(state)")
        }
    }
    
    func testCacheSetPrevious() async throws {
        let previousCacheDate = Date.now
        let currentCacheDate = Date.now.addingTimeInterval(60*15)
        
        try await cache.insertCache(marketData: market, now: previousCacheDate)
        try await cache.insertCache(marketData: market, now: currentCacheDate)
        
        let state = await cache.state
        switch state {
        case .currentAndPreviousSet(let current, let previous):
            XCTAssert(current.marketId == market.id)
            XCTAssert(current.refreshDate == currentCacheDate)
            XCTAssert(previous.marketId == market.id)
            XCTAssert(previous.refreshDate == previousCacheDate)
        default:
            XCTFail("Unexpected state: \(state)")
        }
    }
    
    func testCacheSetCurrentPrevious() async throws {
        let firstCacheDate = Date.now
        let secondCacheDate = Date.now.addingTimeInterval(60*15)
        let currentCacheDate = Date.now.addingTimeInterval(60*30)
        
        try await cache.insertCache(marketData: market, now: firstCacheDate)
        try await cache.insertCache(marketData: market, now: secondCacheDate)
        try await cache.insertCache(marketData: market, now: currentCacheDate)

        let state = await cache.state
        switch state {
        case .currentAndPreviousSet(let current, let previous):
            XCTAssert(current.marketId == market.id)
            XCTAssert(current.refreshDate == currentCacheDate)
            XCTAssert(previous.marketId == market.id)
            XCTAssert(previous.refreshDate == secondCacheDate)
        default:
            XCTFail("Unexpected state: \(state)")
        }
    }
    
    func testClearCache() async throws {
        try await cache.insertCache(marketData: market)
        var state = await cache.state
        
        switch state {
        case .currentSet(_):
            break
        default:
            XCTFail("Unexpected cache state: \(state)")
        }
        
        try await cache.clearCache()
        state = await cache.state
        switch state {
        case .empty:
            return
        default:
            XCTFail("Unexpected cache state: \(state)")
        }
    }
}

//
//  WidgetCacheTests.swift
//  PredictItWidgetTests
//
//  Created by Collin Palmer on 7/16/24.
//

import XCTest
import SwiftData
@testable import PredictItWidget

final class WidgetCacheTests: XCTestCase {
    var cache: WidgetCache!
    var market: PIJSONMarket!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.cache = WidgetCache(configuration: ModelConfiguration(isStoredInMemoryOnly: true))
        guard let url = Bundle(for: Self.self).url(forResource: "7057", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decodedMarket = try? JSONDecoder().decode(PIJSONMarket.self, from: data)
        else {
            XCTFail("Failed to load market json from bundle.")
            return
        }
        
        self.market = decodedMarket
    }


    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCacheEmptyState() throws {
        let state = cache.state(marketId: market.id)
        switch state {
        case .empty:
            return
        default:
            XCTFail("Expected empty state, found: \(state)")
        }
    }
    
    func testCacheCurrentSetState() throws {
        let refreshDate = Date.now
        try cache.insert(market, now: refreshDate)
        let state = cache.state(marketId: market.id)
        switch state {
        case .currentSet(let entry):
            XCTAssert(entry.refreshDate == refreshDate)
            XCTAssert(entry.marketId == market.id)
            XCTAssert(entry.entryType == "\(entry.marketId)_current")
            XCTAssert(entry.contracts.count > 0, "\(entry.contracts.count)")
        default:
            XCTFail("Unexpected state, found: \(state)")
        }
    }
    
    // TODO: Test current and previous
    // TODO: Test caching once current and previous are already set (ie rollover)
    func testCacheCurrentAndPreviousSetState() throws {
        let currentDate = Date.now.addingTimeInterval(WidgetCache.minimumStaleElapsedTime+1)
        let prevDate = Date.now
        
        try cache.insert(market, now: prevDate)
        try cache.insert(market, now: currentDate)
        
        let state = cache.state(marketId: market.id)
        switch state {
        case .currentAndPreviousSet(let currEntry, let prevEntry):
            XCTAssert(currEntry.refreshDate == currentDate)
            XCTAssert(currEntry.marketId == market.id)
            XCTAssert(currEntry.entryType == "\(currEntry.marketId)_current")
            
            XCTAssert(prevEntry.refreshDate == prevDate)
            XCTAssert(prevEntry.marketId == market.id)
            XCTAssert(prevEntry.entryType == "\(prevEntry.marketId)_previous")
        default:
            XCTFail("Unexpected state, found: \(state)")
        }
    }
    
    func testFullCacheRollover() throws {
        let currentDate = Date.now.addingTimeInterval(WidgetCache.minimumStaleElapsedTime+1)
        let prevDate = Date.now
        
        //let current = PreviousMarketDataModel(marketId: market.id, refreshDate: currentDate, entryType: .current)
        //let prev = PreviousMarketDataModel(marketId: market.id, refreshDate: prevDate, entryType: .previous)
        
        try cache.insert(market, now: prevDate)
        try cache.insert(market, now: currentDate)
        
        let newEntryDate = currentDate.addingTimeInterval(WidgetCache.minimumStaleElapsedTime+1)
        //let newEntry = PreviousMarketDataModel(marketId: market.id, refreshDate: newEntryDate, entryType: .current)
        
        try cache.insert(market, now: newEntryDate)
        
        let state = cache.state(marketId: market.id)
        switch state {
        case .currentAndPreviousSet(let currEntry, let prevEntry):
            XCTAssert(currEntry.refreshDate == newEntryDate)
            XCTAssert(currEntry.marketId == market.id)
            XCTAssert(currEntry.entryType == "\(currEntry.marketId)_current")
            
            XCTAssert(prevEntry.refreshDate == currentDate)
            XCTAssert(prevEntry.marketId == market.id)
            XCTAssert(prevEntry.entryType == "\(prevEntry.marketId)_previous")
        default:
            XCTFail("Unexpected state, found: \(state)")
        }
    }
    
    func testCacheNotStale() throws {
        let refreshDate = Date.now
        
        try cache.insert(market, now: refreshDate)
        
        // Insert ignored since the prior cache occurred recently enough.
        try cache.insert(market, now: refreshDate)

        let state = cache.state(marketId: market.id)
        switch state {
        case .currentSet(let entry):
            XCTAssert(entry.refreshDate == refreshDate)
            XCTAssert(entry.marketId == market.id)
            XCTAssert(entry.entryType == "\(entry.marketId)_current")
        default:
            XCTFail("Unexpected state, found: \(state)")
        }
    }
}

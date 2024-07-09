//
//  DBTests.swift
//  PredictItWidgetTests
//
//  Created by Collin Palmer on 7/9/24.
//

import XCTest
import SwiftData
@testable import PredictItWidget

final class DBTests: XCTestCase {
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        let container = try ModelContainer(for: PreviousMarketDataModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        modelContext = ModelContext(container)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCacheStateEmpty() throws {
        let state = try PreviousMarketDataModel.cacheState(selectedMarketId: 0, context: modelContext)
        switch state {
        case .empty:
            return
        case .currentSet(_):
            XCTFail("Unexpected state: current")
        case .currentAndPreviousSet(_,_):
            XCTFail("Unexpected state: current and previous")
        }
    }

    func testCacheStateCurrent() throws {
        let model = PreviousMarketDataModel(marketId: 0, refreshDate: .now, entryType: .current, contracts: [])
        modelContext.insert(model)
        
        let state = try PreviousMarketDataModel.cacheState(selectedMarketId: 0, context: modelContext)
        switch state {
        case .empty:
            XCTFail("Unexpected state: empty")
        case .currentSet(_):
            return
        case .currentAndPreviousSet(_,_):
            XCTFail("Unexpected state: current and previous")
        }
    }

    func testCacheStateCurrentPrevious() throws {
        let currModel = PreviousMarketDataModel(marketId: 0, refreshDate: .now, entryType: .current, contracts: [])
        modelContext.insert(currModel)
        
        let prevModel = PreviousMarketDataModel(marketId: 0, refreshDate: .now, entryType: .previous, contracts: [])
        modelContext.insert(prevModel)
        
        let state = try PreviousMarketDataModel.cacheState(selectedMarketId: 0, context: modelContext)
        switch state {
        case .empty:
            XCTFail("Unexpected state: empty")
        case .currentSet(_):
            XCTFail("Unexpected state: current")
        case .currentAndPreviousSet(_,_):
            return
        }
    }
}

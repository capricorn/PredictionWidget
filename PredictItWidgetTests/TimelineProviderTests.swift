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
}

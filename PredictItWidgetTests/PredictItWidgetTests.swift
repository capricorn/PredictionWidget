//
//  PredictItWidgetTests.swift
//  PredictItWidgetTests
//
//  Created by Collin Palmer on 7/4/24.
//

import XCTest
@testable import PredictItWidget

final class PredictItWidgetTests: XCTestCase {
    func testDecodeJSONMarket() throws {
        guard let url = Bundle(for: Self.self).url(forResource: "7057", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else {
            XCTFail("Failed to load market XML from bundle.")
            return
        }
        
        let marketData = try JSONDecoder().decode(PIJSONMarket.self, from: data)
        XCTAssert(marketData.id == 7057)
        XCTAssert(marketData.name == "Who will win the 2024 Democratic presidential nomination?")
        XCTAssert(marketData.shortName == "Democratic 2024 presidential nominee?")
        XCTAssert(marketData.imageURL == URL(string: "https://az620379.vo.msecnd.net/images/Markets/4925e586-edc2-4238-8237-e8c2b2fa429d.png")!)
        XCTAssert(marketData.marketURL == URL(string: "https://www.predictit.org/markets/detail/7057/Who-will-win-the-2024-Democratic-presidential-nomination")!)
        XCTAssert(marketData.contracts.count > 1)

    }
    
    func testDecodeActiveJSONMarkets() throws {
        guard let url = Bundle(for: Self.self).url(forResource: "all", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else {
            XCTFail("Failed to load market XML from bundle.")
            return
        }
        
        let markets = try JSONDecoder().decode(PIJSONAllMarkets.self, from: data).markets
        XCTAssert(markets.count > 1)
        
        guard let marketData = markets.first else {
            XCTFail("Failed to load first market entry from all markets json.")
            return
        }
        
        XCTAssert(marketData.id == 6867)
        XCTAssert(marketData.name == "Which party will win the 2024 U.S. presidential election?")
        XCTAssert(marketData.shortName == "Which party wins the presidency in 2024?")
        XCTAssert(marketData.imageURL == URL(string: "https://az620379.vo.msecnd.net/images/Markets/4a0705c2-577f-47f6-afa5-d1510d771597.jpg")!)
        XCTAssert(marketData.marketURL == URL(string: "https://www.predictit.org/markets/detail/6867/Which-party-will-win-the-2024-US-presidential-election")!)
        XCTAssert(marketData.contracts.count > 1)

    }
}

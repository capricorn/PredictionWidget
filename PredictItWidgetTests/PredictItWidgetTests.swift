//
//  PredictItWidgetTests.swift
//  PredictItWidgetTests
//
//  Created by Collin Palmer on 7/4/24.
//

import XCTest
import XMLCoder
@testable import PredictItWidget

final class PredictItWidgetTests: XCTestCase {
    func testDecodeMarketData() throws {
        guard let url = Bundle(for: Self.self).url(forResource: "7057", withExtension: "xml"),
              let data = try? Data(contentsOf: url)
        else {
            XCTFail("Failed to load market XML from bundle.")
            return
        }
        
        let marketData = try XMLDecoder().decode(PIMarketData.self, from: data)
        
        XCTAssert(marketData.id == "7057")
        XCTAssert(marketData.name == "Who will win the 2024 Democratic presidential nomination?")
        XCTAssert(marketData.shortName == "Democratic 2024 presidential nominee?")
        XCTAssert(marketData.imageURL == URL(string: "https://az620379.vo.msecnd.net/images/Markets/4925e586-edc2-4238-8237-e8c2b2fa429d.png")!)
        XCTAssert(marketData.marketURL == URL(string: "https://www.predictit.org/markets/detail/7057/Who-will-win-the-2024-Democratic-presidential-nomination"))
        
        XCTAssert(marketData.timestamp == "2024-07-04T22:37:04.4652386")
        XCTAssert(marketData.status == "Open")
    }
    
    func testDecodeMarketContracts() throws {
        guard let url = Bundle(for: Self.self).url(forResource: "7057", withExtension: "xml"),
          let data = try? Data(contentsOf: url)
        else {
            XCTFail("Failed to load market XML from bundle.")
            return
        }
        
        let marketData = try XMLDecoder().decode(PIMarketData.self, from: data)
        
        guard let firstContract = marketData.contracts.first else {
            XCTFail("Failed to find first contract.")
            return
        }
        
        XCTAssert(firstContract.id == "24808")
        XCTAssert(firstContract.endDate == "NA")
        XCTAssert(firstContract.imageURL == URL(string: "https://az620379.vo.msecnd.net/images/Contracts/small_42e624ca-be5f-4c3e-8939-86bb42b0314d.jpg")!)
        XCTAssert(firstContract.name == "Kamala Harris")
        XCTAssert(firstContract.shortName == "Harris")
        XCTAssert(firstContract.status == "Open")
        XCTAssert(firstContract.lastTradePrice == 43)
        XCTAssert(firstContract.bestYesAsk == 43)
        XCTAssert(firstContract.bestNoAsk == 59)
        XCTAssert(firstContract.bestYesBid == 41)
        XCTAssert(firstContract.bestNoBid == 57)
        XCTAssert(firstContract.prevClosePrice == 36)
        XCTAssert(firstContract.displayOrder == "0")
    }
    
    func testDecodeAllMarkets() throws {
        guard let url = Bundle(for: Self.self).url(forResource: "all", withExtension: "xml"),
              let data = try? Data(contentsOf: url)
        else {
            XCTFail("Failed to load market XML from bundle.")
            return
        }
        
        _ = try XMLDecoder().decode(PIMarketList.self, from: data)
    }
}

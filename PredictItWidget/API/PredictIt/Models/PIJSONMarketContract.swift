//
//  PIJSONMarketContract.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/5/24.
//

import Foundation

struct PIJSONMarketContract: Codable, Identifiable {
    var id: Int
    var endDate: String
    var imageURL: URL
    var name: String
    var shortName: String
    var status: String
    var lastTradePrice: Int?
    var bestYesAsk: Int?
    var bestNoAsk: Int?
    var bestYesBid: Int?
    var bestNoBid: Int?
    var displayOrder: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case endDate = "dateEnd"
        case imageURL = "image"
        case name
        case shortName
        case status
        case lastTradePrice
        case bestYesAsk = "bestBuyYesCost"
        case bestNoAsk = "bestBuyNoCost"
        case bestYesBid = "bestSellYesCost"
        case bestNoBid = "bestSellNoCost"
        case displayOrder
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.endDate = try container.decode(String.self, forKey: .endDate)
        self.imageURL = try container.decode(URL.self, forKey: .imageURL)
        self.name = try container.decode(String.self, forKey: .name)
        self.shortName = try container.decode(String.self, forKey: .shortName)
        self.status = try container.decode(String.self, forKey: .status)
        
        if let lastTradePrice = try container.decodeIfPresent(Double.self, forKey: .lastTradePrice) {
            self.lastTradePrice = Int(round(lastTradePrice*100.0))
        }
        
        if let bestYesAsk = try container.decodeIfPresent(Double.self, forKey: .bestYesAsk) {
            self.bestYesAsk = Int(round(bestYesAsk*100.0))
        }

        if let bestNoAsk = try container.decodeIfPresent(Double.self, forKey: .bestNoAsk) {
            self.bestNoAsk = Int(round(bestNoAsk*100.0))
        }
        
        if let bestYesBid = try container.decodeIfPresent(Double.self, forKey: .bestYesBid) {
            self.bestYesBid = Int(round(bestYesBid*100.0))
        }
        
        if let bestNoBid = try container.decodeIfPresent(Double.self, forKey: .bestNoBid) {
            self.bestNoBid = Int(round(bestNoBid*100.0))
        }

        self.displayOrder = try container.decode(Int.self, forKey: .displayOrder)
    }
}

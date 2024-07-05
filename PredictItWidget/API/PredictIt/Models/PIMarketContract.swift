//
//  PIMarketContract.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/4/24.
//

import Foundation

struct PIMarketContract: Codable, Identifiable {
    var id: String
    var endDate: String // TODO: Treat as an actual Date
    var imageURL: URL
    var name: String
    var shortName: String
    var status: String  // TODO: Enum?
    var lastTradePrice: Int // in cents; Dollar unit make sense here? ie Measurement<USD>.
    var bestYesAsk: Int // cents
    var bestNoAsk: Int  // cents
    var bestYesBid: Int // cents
    var bestNoBid: Int  // cents
    var prevClosePrice: Int // cents
    var displayOrder: String    // TODO: What's this?
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case endDate = "DateEnd"
        case imageURL = "Image"
        case name = "Name"
        case shortName = "ShortName"
        case status = "Status"
        case lastTradePrice = "LastTradePrice"
        case bestYesAsk = "BestBuyYesCost"
        case bestNoAsk = "BestBuyNoCost"
        case bestYesBid = "BestSellYesCost"
        case bestNoBid = "BestSellNoCost"
        case prevClosePrice = "LastClosePrice"
        case displayOrder = "DisplayOrder"
    }
    
    enum ContractCodingKeys: String, CodingKey {
        case marketContract = "MarketContract"
    }
    
    init(from decoder: any Decoder) throws {
        let contractContainer = try decoder.container(keyedBy: ContractCodingKeys.self)
        let container = try contractContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .marketContract)
        self.id = try container.decode(String.self, forKey: .id)
        self.endDate = try container.decode(String.self, forKey: .endDate)
        self.imageURL = try container.decode(URL.self, forKey: .imageURL)
        self.name = try container.decode(String.self, forKey: .name)
        self.shortName = try container.decode(String.self, forKey: .shortName)
        self.status = try container.decode(String.self, forKey: .status)
        
        let lastTradePrice = try container.decode(Double.self, forKey: .lastTradePrice)
        self.lastTradePrice = Int(round(lastTradePrice*100.0))
        
        let bestYesAsk = try container.decode(Double.self, forKey: .bestYesAsk)
        self.bestYesAsk = Int(round(bestYesAsk*100.0))
        
        let bestNoAsk = try container.decode(Double.self, forKey: .bestNoAsk)
        self.bestNoAsk = Int(round(bestNoAsk*100.0))
        
        let bestYesBid = try container.decode(Double.self, forKey: .bestYesBid)
        self.bestYesBid = Int(round(bestYesBid*100.0))
        
        let bestNoBid = try container.decode(Double.self, forKey: .bestNoBid)
        self.bestNoBid = Int(round(bestNoBid*100.0))
        
        let prevClosePrice = try container.decode(Double.self, forKey: .prevClosePrice)
        self.prevClosePrice = Int(round(prevClosePrice*100.0))
        
        self.displayOrder = try container.decode(String.self, forKey: .displayOrder)
    }
}

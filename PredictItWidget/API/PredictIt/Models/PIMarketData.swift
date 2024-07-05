//
//  PIMarketData.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/4/24.
//

import Foundation

struct PIMarketData: Codable, Identifiable {
    var id: String
    var name: String
    var shortName: String
    var imageURL: URL
    var marketURL: URL
    var contracts: [PIMarketContract]
    var timestamp: String
    var status: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "Name"
        case shortName = "ShortName"
        case imageURL = "Image"
        case marketURL = "URL"
        case contracts = "Contracts"
        case timestamp = "TimeStamp"
        case status = "Status"
    }
}

struct PIMarkets: Codable {
    var marketData: [PIMarketData]
    
    enum CodingKeys: String, CodingKey {
        case marketData = "MarketData"
    }
}

struct PIMarketList: Codable {
    var markets: PIMarkets
    
    enum CodingKeys: String, CodingKey {
        case markets = "Markets"
    }
}

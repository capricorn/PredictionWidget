//
//  PIJSONMarket.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/5/24.
//

import Foundation

struct PIJSONAllMarkets: Codable {
    var markets: [PIJSONMarket]
}

struct PIJSONMarket: Codable, Identifiable {
    var id: Int
    var name: String
    var shortName: String
    var imageURL: URL
    var marketURL: URL
    // TODO: contracts
    var contracts: [PIJSONMarketContract]
    var timestamp: String
    // TODO: Verify all plausible states?
    var status: String
    
    enum MarketStatus: String {
        case closed = "Closed"
        case open = "Open"
    }
    
    var archived: Bool {
        return status == MarketStatus.closed.rawValue
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case shortName
        case imageURL = "image"
        case marketURL = "url"
        case contracts
        case timestamp = "timeStamp"
        case status = "status"
    }
    
    var market: Market {
        Market(id: self.id, name: self.shortName, contracts: self.contracts.map { $0.marketContract })
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.shortName = try container.decode(String.self, forKey: .shortName)
        
        let imageURL = try container.decode(String.self, forKey: .imageURL)
        self.imageURL = URL(string: imageURL)!
        
        let marketURL = try container.decode(String.self, forKey: .marketURL)
        self.marketURL = URL(string: marketURL)!
        
        //var contractContainer = try container.nestedUnkeyedContainer(forKey: .contracts)
        self.contracts = try container.decode([PIJSONMarketContract].self, forKey: .contracts)
        //self.contracts = try contractContainer.decode([PIJSONMarketContract].self)

        self.timestamp = try container.decode(String.self, forKey: .timestamp)
        self.status = try container.decode(String.self, forKey: .status)
    }
}

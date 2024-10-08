//
//  PreviousMarketDataModel.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/9/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class PreviousMarketDataModel {
    
    enum EntryType: String, Codable {
        case current
        case previous
    }
    
    enum CacheState {
        case empty
        case currentSet(PreviousMarketDataModel)
        case currentAndPreviousSet(current: PreviousMarketDataModel, previous: PreviousMarketDataModel)
    }
    
    var marketId: Int
    var name: String
    var refreshDate: Date
    // Would use the enum here but swift predicates fail.
    // (Should only have a single set of current + previous
    @Attribute(.unique)
    var entryType: String
    
    @Relationship(deleteRule: .cascade, inverse: \ContractEntryModel.market)
    var contracts: [ContractEntryModel] = []
    
    init(marketId: Int, name: String, refreshDate: Date, entryType: EntryType) {
        self.marketId = marketId
        self.name = name
        self.refreshDate = refreshDate
        self.entryType = entryType.rawValue
        //self.contracts = contracts
    }
    
    static func cacheState(selectedMarketId: Int, context: ModelContext) throws -> CacheState {
        let currType = PreviousMarketDataModel.EntryType.current.rawValue
        let pred = #Predicate<PreviousMarketDataModel> { (model: PreviousMarketDataModel) in
            model.marketId == selectedMarketId && model.entryType == currType
        }
        let query = FetchDescriptor(predicate: pred)
        let results = try context.fetch(query)
        
        if results.isEmpty {
            return .empty
        }
        
        let prevType = PreviousMarketDataModel.EntryType.previous.rawValue
        let prevPred = #Predicate<PreviousMarketDataModel> { (model: PreviousMarketDataModel) in
            model.marketId == selectedMarketId && model.entryType == prevType
        }
        let prevQuery = FetchDescriptor(predicate: prevPred)
        let prevResults = try context.fetch(prevQuery)
        
        if prevResults.isEmpty {
            return .currentSet(results.first!)
        }
        
        return .currentAndPreviousSet(current: results.first!, previous: prevResults.first!)
    }
    
}

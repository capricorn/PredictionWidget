//
//  ContractEntryModel.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/9/24.
//

import Foundation
import SwiftData

@Model
class ContractEntryModel {
    let id: Int
    let price: Int
    let name: String
    //@Attribute(.ephemeral)
    //var market: PreviousMarketDataModel? = nil
    
    init(id: Int, price: Int, name: String) {
        self.id = id
        self.price = price
        self.name = name
    }
}

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
    var id: Int
    var price: Int?
    var name: String
    // NB. Important this is nil -- otherwise relationships seem to break.
    var market: PreviousMarketDataModel?

    init(id: Int, price: Int?, name: String, market: PreviousMarketDataModel) {
        self.id = id
        self.price = price
        self.name = name
        self.market = market
    }
}

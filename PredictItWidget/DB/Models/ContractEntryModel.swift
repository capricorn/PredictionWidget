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
    
    init(id: Int, price: Int) {
        self.id = id
        self.price = price
    }
}

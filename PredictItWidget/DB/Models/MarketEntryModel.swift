//
//  MarketEntryModel.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/13/24.
//

import Foundation
import SwiftData

@Model
class MarketEntryModel {
    @Attribute(.unique)
    var id: Int
    var name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

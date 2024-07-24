//
//  AppSchema.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/24/24.
//

import Foundation
import SwiftData

fileprivate let schemaTypes: [any PersistentModel.Type] = [
    PreviousMarketDataModel.self,
    ContractEntryModel.self,
    MarketEntryModel.self
]

let appSchema = Schema(schemaTypes, version: Schema.Version(1,0,0))

// TODO: Later define migrator here

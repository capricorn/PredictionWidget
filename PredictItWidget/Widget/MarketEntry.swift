//
//  MarketEntry.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/23/24.
//

import Foundation
import WidgetKit

struct MarketContract: Identifiable {
    let id: Int
    var name: String
    var cents: Int?
    var change: Int?
}

struct Market: Identifiable {
    let id: Int
    var name: String
    var contracts: [MarketContract]
    var archived: Bool = false
}

enum EntryType {
    /// `nil` if no market is selected.
    case market(Market?)
    case error
}

// TODO: -- define necessary fields
struct MarketEntry: TimelineEntry {
    let date: Date
    //let configuration: ConfigurationAppIntent
    let type: EntryType
}

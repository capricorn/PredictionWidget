//
//  UserDefaultsExtensions.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/7/24.
//

import Foundation

enum PredictionWidgetUserDefaultsKeys: String {
    case widgetMarket
}

enum PredictionWidgetUserDefaultsValue {
    case widgetMarket(marketId: Int?)
    
    var key: PredictionWidgetUserDefaultsKeys {
        switch self {
        case .widgetMarket(_):
            return .widgetMarket
        }
    }
}

extension UserDefaults {
    static var predictionWidget: UserDefaults! {
        UserDefaults(suiteName: "group.goatfish.PredictionWidget")
    }
    
    func set(_ value: PredictionWidgetUserDefaultsValue) {
        switch value {
        case .widgetMarket(let marketId):
            UserDefaults.predictionWidget.set(marketId, forKey: value.key.rawValue)
        }
    }
}


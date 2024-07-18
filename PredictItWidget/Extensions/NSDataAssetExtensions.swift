//
//  NSDataAssetExtensions.swift
//  PredictItWidget
//
//  Created by Collin Palmer on 7/18/24.
//

import Foundation
import UIKit

enum PreviewAssetName: String {
    case json7057 = "7057"
    case json8069Archived = "8069_archived"
    case jsonAll = "all"
}

extension NSDataAsset {
    convenience init(preview: PreviewAssetName) {
        self.init(name: preview.rawValue)!
    }
}

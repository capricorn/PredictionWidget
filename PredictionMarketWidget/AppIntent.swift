//
//  AppIntent.swift
//  PredictionMarketWidget
//
//  Created by Collin Palmer on 7/6/24.
//

import WidgetKit
import AppIntents

// Just start with the cache for now?
struct MarketQuery: EntityQuery {
    typealias Entity = MarketDetail
    
    func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
        return try await suggestedEntities()
    }
    
    func suggestedEntities() async throws -> [Entity] {
        let entries = await CacheActor.shared.markets
        
        return entries.map { MarketDetail(id: $0.id, name: $0.name) }
    }
}

struct MarketDetail: AppEntity {
    let id: Int
    let name: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "MarketDetails"
    static var defaultQuery: MarketQuery = MarketQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(stringLiteral: "\(name)")
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")
    
    // WIP: List available cached markets
    // Modify the main app to store all market IDs (short name, id) on refresh
    // Then query swiftdata for these (it will reference the same app group as the main app)

    // An example configurable parameter.
    // Pass options provider here
    /*
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
     */
    @Parameter(title: "Market")
    var selectedMarket: MarketDetail
    
    
}

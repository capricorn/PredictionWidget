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
        
        return entries
            .map { MarketDetail(id: $0.id, name: $0.name) }
            .sorted(by: { $0.name < $1.name })
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
    
    // TODO: Requires special 'None' option..?
    @Parameter(title: "Market")
    var selectedMarket: MarketDetail?
}

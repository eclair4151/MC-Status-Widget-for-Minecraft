//
//  ThemeIntentTypeAppEntity.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/28/23.
//

import Foundation
import AppIntents

struct ThemeIntentTypeAppEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Theme Intent Type")

    struct ThemeIntentTypeAppEntityQuery: EntityQuery {
        func entities(for identifiers: [ThemeIntentTypeAppEntity.ID]) async throws -> [ThemeIntentTypeAppEntity] {
            // TODO: return ThemeIntentTypeAppEntity entities with the specified identifiers here.
            return []
        }

        func suggestedEntities() async throws -> [ThemeIntentTypeAppEntity] {
            // TODO: return likely ThemeIntentTypeAppEntity entities here.
            // This method is optional; the default implementation returns an empty array.
            return []
        }
    }
    static var defaultQuery = ThemeIntentTypeAppEntityQuery()

    var id: String // if your identifier is not a String, conform the entity to EntityIdentifierConvertible.
    var displayString: String
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(displayString)")
    }

    init(id: String, displayString: String) {
        self.id = id
        self.displayString = displayString
    }
}


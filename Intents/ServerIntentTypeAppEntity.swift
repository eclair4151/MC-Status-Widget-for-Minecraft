//
//  ServerIntentTypeAppEntity.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/28/23.
//

import Foundation
import AppIntents

struct ServerIntentTypeAppEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Server Intent Type")

    struct ServerIntentTypeAppEntityQuery: EntityQuery {
        func entities(for identifiers: [ServerIntentTypeAppEntity.ID]) async throws -> [ServerIntentTypeAppEntity] {
            // TODO: return ServerIntentTypeAppEntity entities with the specified identifiers here.
            return []
        }

        func suggestedEntities() async throws -> [ServerIntentTypeAppEntity] {
            // TODO: return likely ServerIntentTypeAppEntity entities here.
            // This method is optional; the default implementation returns an empty array.
            return []
        }
    }
    static var defaultQuery = ServerIntentTypeAppEntityQuery()

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


//
//  ServerIntentTypeAppEntity.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/28/23.
//

import Foundation
import AppIntents
import MCStatusDataLayer

//this is bascially a duplicate of the SavedServerEntity, but had to be split into its own thing to maintain widget compatibility
struct ServerIntentTypeAppEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Server Intent Type")

    struct ServerIntentTypeAppEntityQuery: EntityQuery {
        func entities(for identifiers: [ServerIntentTypeAppEntity.ID]) async throws -> [ServerIntentTypeAppEntity] {
            let container = SwiftDataHelper.getModelContainter()
            var result:[ServerIntentTypeAppEntity] = []
            for id in identifiers {
                guard let serverUUID = UUID(uuidString: id), let server = await SwiftDataHelper.getSavedServerById(container: container, server_id: serverUUID) else {
                    continue
                }
                result.append(ServerIntentTypeAppEntity(id: server.id.uuidString, displayString: server.name))
            }
            return result
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


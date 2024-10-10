//
//  ThemeIntentTypeAppEntity.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/28/23.
//

import Foundation
import AppIntents

enum Theme:String, CaseIterable {
    case dark = "Dark"
    case light = "Light"
    case blue = "Blue"
    case green = "Green"
    case red = "Red"
    case auto = "Auto"
}


struct ThemeIntentTypeAppEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Theme Intent Type")

    struct ThemeIntentTypeAppEntityQuery: EntityQuery {
        func entities(for identifiers: [ThemeIntentTypeAppEntity.ID]) async throws -> [ThemeIntentTypeAppEntity] {
            return identifiers.map { id in
                ThemeIntentTypeAppEntity(id: id, displayString: id)
            }
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


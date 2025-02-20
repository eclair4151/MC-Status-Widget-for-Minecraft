import AppIntents

enum Theme: String, CaseIterable {
    case dark = "Dark",
         light = "Light",
         blue = "Blue",
         green = "Green",
         red = "Red",
         auto = "Auto"
}


struct ThemeIntentTypeAppEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Theme Intent Type")
    
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
    
    struct ThemeIntentTypeAppEntityQuery: EntityQuery {
        func entities(for identifiers: [ThemeIntentTypeAppEntity.ID]) async throws -> [ThemeIntentTypeAppEntity] {
            identifiers.map { id in
                ThemeIntentTypeAppEntity(id: id, displayString: id)
            }
        }
        
        func suggestedEntities() async throws -> [ThemeIntentTypeAppEntity] {
            Theme.allCases.map { themeEnum in
                ThemeIntentTypeAppEntity(id: themeEnum.rawValue, displayString: themeEnum.rawValue)
            }
        }
        
        func defaultResult() async -> ThemeIntentTypeAppEntity? {
            ThemeIntentTypeAppEntity(id: Theme.auto.rawValue, displayString: Theme.auto.rawValue)
        }
    }
}

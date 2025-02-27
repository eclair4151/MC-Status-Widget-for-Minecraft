import Foundation
import AppIntents
import MCStatsDataLayer

// this is bascially a duplicate of the SavedServerEntity, but had to be split into its own thing to maintain widget compatibility with people who had widgets pre 2.0 (id is string instead of UUID, variable is named displayString instead of serverName)
struct ServerIntentTypeAppEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Server Intent Type")
    
    static var defaultQuery = ServerIntentTypeAppEntityQuery()
    
    // if your identifier is not a String, conform the entity to EntityIdentifierConvertible
    var id: String
    var displayString: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(displayString)")
    }
    
    init(id: String, displayString: String) {
        self.id = id
        self.displayString = displayString
    }
    
    struct ServerIntentTypeAppEntityQuery: EntityQuery {
        func entities(for identifiers: [ServerIntentTypeAppEntity.ID]) async throws -> [ServerIntentTypeAppEntity] {
            let container = SwiftDataHelper.getModelContainter()
            var result: [ServerIntentTypeAppEntity] = []
            
            for id in identifiers {
                guard
                    let serverUUID = UUID(uuidString: id),
                    let server = await SwiftDataHelper.getSavedServerById(serverUUID, from: container)
                else {
                    continue
                }
                
                result.append(ServerIntentTypeAppEntity(
                    id: server.id.uuidString,
                    displayString: server.name
                ))
            }
            
            return result
        }
        
        func suggestedEntities() async throws -> [ServerIntentTypeAppEntity] {
            let container = SwiftDataHelper.getModelContainter()
            
            let res = await SwiftDataHelper.getSavedServers(container).map { server in
                ServerIntentTypeAppEntity(
                    id: server.id.uuidString,
                    displayString: server.name
                )
            }
            
            return res
        }
        
        // This code is broken (bug in apple?), default called on first widget, then never called again, so all subsequent widgets show old data
        // Better to just not set default and force user to pick a server
        //        https://developer.apple.com/forums/thread/766959
        
        //        func defaultResult() async -> ServerIntentTypeAppEntity? {
        //            let container = SwiftDataHelper.getModelContainter()
        //            let servers = await SwiftDataHelper.getSavedServers(container: container)
        //
        //            guard servers.count >= 1, let server = servers.first else {
        //                return nil
        //            }
        //
        //            return ServerIntentTypeAppEntity(id: server.id.uuidString, displayString: server.name)
        //        }
    }
}

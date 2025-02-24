import AppIntents
import MCStatsDataLayer

struct SavedServerEntity: AppEntity {
    static var defaultQuery = SavedServerQuery()
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Server"
    
#warning("Add description & image")
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(serverName)"
            // subtitle: "",
            // image: <#T##DisplayRepresentation.Image?#>
        )
    }
    
    var id: UUID
    var serverName: String
}

struct SavedServerQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [SavedServerEntity] {
        let container = SwiftDataHelper.getModelContainter()
        var result: [SavedServerEntity] = []
        
        for id in identifiers {
            guard let server = await SwiftDataHelper.getSavedServerById(id, from: container) else {
                continue
            }
            
            result.append(SavedServerEntity(
                id: server.id,
                serverName: server.name
            ))
        }
        
        return result
    }
    
    func suggestedEntities() async throws -> [SavedServerEntity] {
        let container = SwiftDataHelper.getModelContainter()
        let servers = await SwiftDataHelper.getSavedServers(container)
        
        return servers.map {
            SavedServerEntity(id: $0.id, serverName: $0.name)
        }
    }
}

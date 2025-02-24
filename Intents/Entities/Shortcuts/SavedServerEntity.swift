import SwiftUI
import AppIntents
import MCStatsDataLayer

struct SavedServerEntity: AppEntity {
    static var defaultQuery = SavedServerQuery()
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Server"
    
    var displayRepresentation: DisplayRepresentation {
        let uiImage = ImageHelper.favIconString(icon) ?? UIImage(named: "DefaultIcon") ?? UIImage()
        let imageData = uiImage.pngData() ?? Data()
        
        return DisplayRepresentation(
            title: "\(serverName)",
            subtitle: "\(type)",
            image: .init(data: imageData)
        )
    }
    
    var id: UUID
    var serverName: String
    var icon: String
    var type: String
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
                serverName: server.name,
                icon: server.serverIcon,
                type: server.serverType.rawValue
            ))
        }
        
        return result
    }
    
    func suggestedEntities() async throws -> [SavedServerEntity] {
        let container = SwiftDataHelper.getModelContainter()
        let servers = await SwiftDataHelper.getSavedServers(container)
        
        return servers.map {
            SavedServerEntity(
                id: $0.id,
                serverName: $0.name,
                icon: $0.serverIcon,
                type: $0.serverType.rawValue
            )
        }
    }
}

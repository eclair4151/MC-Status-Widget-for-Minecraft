//
//  ServerStatusEntity.swift
//  MCStatusAppIntentsExtension
//
//  Created by Tomer Shemesh on 9/9/23.
//

import Foundation
import AppIntents
struct ServerStatusEntity: AppEntity {
    
    var serverName: String
    
    @Property(title: "Online Status")
    var onlineStatus: String

    @Property(title: "Player Count")
    var playerCount: Int
    
    @Property(title: "Server Status Json")
    var statusDict: String
    
    var id: UUID

    static var defaultQuery = ServerStausQuery()

    static var typeDisplayRepresentation = TypeDisplayRepresentation("Server Status")

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(serverName) is \(onlineStatus.lowercased()) with \(playerCount) players.")
    }
}



struct ServerStausQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [ServerStatusEntity] {
        return []
    }
    
    func suggestedEntities() async throws -> [ServerStatusEntity] {
       return []
    }
}

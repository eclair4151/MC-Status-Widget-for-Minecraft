//
//  ServerStatusEntity.swift
//  MCStatusAppIntentsExtension
//
//  Created by Tomer Shemesh on 9/9/23.
//

import Foundation
import AppIntents
import MCStatusDataLayer
struct ServerStatusEntity: AppEntity {
    
    var serverName: String
    var querySource = "Phone"
    
    @Property(title: "Online Status")
    var onlineStatus: String

    @Property(title: "Player Count")
    var playerCount: Int
    
    @Property(title: "MOTD")
    var motd: String
    
    @Property(title: "Player Sample")
    var playerSample: String

    
    var id: UUID

    static var defaultQuery = ServerStausQuery()

    static var typeDisplayRepresentation = TypeDisplayRepresentation("Server Status")

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(serverName) is \(onlineStatus.lowercased()) with \(playerCount) players.")
    }
    
    init(serverId: UUID, serversName: String, serverStatus: ServerStatus) {
        id = serverId
        serverName = serversName
        playerCount = serverStatus.onlinePlayerCount
        onlineStatus = serverStatus.status.rawValue
        motd = serverStatus.description?.getRawText() ?? ""
        playerSample = serverStatus.playerSample.map{ $0.name }.joined(separator: ",")
        querySource = (serverStatus.source == .ThirdParty) ? "Web" : "Phone"
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

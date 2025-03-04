import AppIntents
import MCStatsDataLayer

struct ServerStatusEntity: AppEntity {
    var serverName: String
    var querySource = "Phone"
    
    @Property(title: "Online Status")
    var onlineStatus: String
    
    @Property(title: "Player Count")
    var playerCount: Int
    
    @Property(title: "Max Player Count")
    var maxPlayerCount: Int
    
    @Property(title: "MOTD")
    var motd: String
    
    @Property(title: "Player Sample")
    var playerSample: String
    
    var id: UUID
    
    static var defaultQuery = ServerStausQuery()
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Server Status"
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(serverName) is \(onlineStatus.lowercased()) with \(playerCount) players.")
    }
    
    init(serverId: UUID, serversName: String, serverStatus: ServerStatus) {
        id = serverId
        serverName = serversName
        playerCount = serverStatus.onlinePlayerCount
        maxPlayerCount = serverStatus.maxPlayerCount
        onlineStatus = serverStatus.status.rawValue
        motd = serverStatus.description?.getRawText() ?? ""
        playerSample = serverStatus.playerSample.map(\.name).joined(separator: ",")
        querySource = (serverStatus.source == .ThirdParty) ? "Web" : "Phone"
    }
}

struct ServerStausQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [ServerStatusEntity] {
        []
    }
    
    func suggestedEntities() async throws -> [ServerStatusEntity] {
        []
    }
}

import Foundation
import SwiftData

public enum ServerType: String, Codable {
    case Java, Bedrock
}

@Model
public class SavedMinecraftServer: Identifiable, Codable {
    public var id = UUID()
    public var name = ""
    public var serverUrl = ""
    public var serverPort = 0
    public var srvServerUrl = ""
    public var srvServerPort = 0
    public var serverIcon = ""
    public var displayOrder = 0
    public var serverType = ServerType.Java
    
    public static func initialize(id:UUID, serverType: ServerType, name: String, serverUrl: String, serverPort: Int, srvServerUrl: String = "", srvServerPort: Int = 1, serverIcon: String = "", displayOrder: Int = 0) -> SavedMinecraftServer {
        let server = SavedMinecraftServer()
        server.id = id
        server.name = name
        server.serverUrl = serverUrl
        server.serverPort = serverPort
        server.srvServerUrl = srvServerUrl
        server.srvServerPort = srvServerPort
        server.serverIcon = serverIcon
        server.displayOrder = displayOrder
        server.serverType = serverType
        return server
    }
    
    init() {
        
    }
    
    public enum CodingKeys: CodingKey {
        case id, name, serverUrl, serverPort, srvServerUrl, srvServerPort, serverIcon, displayOrder, serverType
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.serverUrl = try container.decode(String.self, forKey: .serverUrl)
        self.serverPort = try container.decode(Int.self, forKey: .serverPort)
        self.srvServerUrl = try container.decode(String.self, forKey: .srvServerUrl)
        self.srvServerPort = try container.decode(Int.self, forKey: .srvServerPort)
        self.serverIcon = try container.decode(String.self, forKey: .serverIcon)
        self.displayOrder = try container.decode(Int.self, forKey: .displayOrder)
        self.serverType = try container.decode(ServerType.self, forKey: .serverType)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(serverUrl, forKey: .serverUrl)
        try container.encode(serverPort, forKey: .serverPort)
        try container.encode(srvServerUrl, forKey: .srvServerUrl)
        try container.encode(srvServerPort, forKey: .srvServerPort)
        try container.encode(serverIcon, forKey: .serverIcon)
        try container.encode(displayOrder, forKey: .displayOrder)
        try container.encode(serverType, forKey: .serverType)
    }
}

import Foundation

public class WatchRequestMessage: Codable {
    public var servers: [SavedMinecraftServer] = []
    
    public init() {
        
    }
}

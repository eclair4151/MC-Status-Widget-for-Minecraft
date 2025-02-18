import Foundation
import SwiftData
import MCStatusDataLayer

class RealmDbMigrationHelper {
    public init() {}
    
    // Singleton instance for easy access
    static let shared = RealmDbMigrationHelper()
    
    private class LegacyServerType {
        static let SERVER_TYPE_JAVA = 0
        static let SERVER_TYPE_BEDROCK = 1
        static let SERVER_TYPE_JAVA_REALMS = 2
        static let SERVER_TYPE_BEDROCK_REALMS = 3
    }
    
    private var migrationInProgress = false
    
    //server model for the database
    private class LegacySavedServer: Codable {
        var id = UUID().uuidString
        var name = ""
        var serverUrl = ""
        var serverIcon = ""
        var order = 100
        var showInWidget = false
        var serverType = LegacyServerType.SERVER_TYPE_JAVA
    }
    
    private func loadServerDump() -> [LegacySavedServer]? {
        let defaults = UserDefaults.standard
        
        guard let jsonString = defaults.string(forKey: "serverDump") else {
            return nil
        }
        
        let jsonDecoder = JSONDecoder()
        
        do {
            let servers = try jsonDecoder.decode([LegacySavedServer].self, from: jsonString.data(using: .utf8)!)
            return servers
        } catch {
            print("Failed to decode saved servers: \(error)")
            return nil
        }
    }
    
    
    private func convertToSwiftData(savedServer: LegacySavedServer) -> SavedMinecraftServer? {
        let serverType: ServerType = (savedServer.serverType == LegacyServerType.SERVER_TYPE_JAVA) ? .Java : .Bedrock
        let serverUrlparts = savedServer.serverUrl.split(separator:  ":")
        var serverUrl = ""
        var serverPort = (savedServer.serverType == LegacyServerType.SERVER_TYPE_JAVA) ? 25565 : 19132
        
        if serverUrlparts.isEmpty {
            return nil
        }
        
        serverUrl = String(serverUrlparts[0])
        
        if serverUrlparts.count > 1, let port = Int(serverUrlparts[1]) {
            serverPort = port
        }
        
        let newServer = SavedMinecraftServer.initialize(
            id: UUID(uuidString: savedServer.id) ?? UUID(),
            serverType: serverType,
            name: savedServer.name,
            serverUrl: serverUrl,
            serverPort: serverPort,  // default port, update this as needed
            srvServerUrl: "",
            srvServerPort: 0,
            serverIcon: savedServer.serverIcon,
            displayOrder: savedServer.order
        )
        
        return newServer
    }
    
    func nukeSavedServers() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "serverDump")
        print("Saved servers nuked from UserDefaults.")
    }
    
    @MainActor func migrateServersToSwiftData() {
        guard !migrationInProgress else {
            print("migrationInProgress is true, skipping migration.")
            return
        }
        
        self.migrationInProgress = true
        
        defer {
            self.migrationInProgress = false
        }
        
        guard let savedServers = loadServerDump() else {
            print("No saved servers found in UserDefaults.")
            return
        }
        
        let context = ModelContext(SwiftDataHelper.getModelContainter())
        
        for savedServer in savedServers {
            if let newServer = convertToSwiftData(savedServer: savedServer) {
                context.insert(newServer)
            }
        }
        
        do {
            try context.save()
            nukeSavedServers()
            print("Successfully migrated servers to SwiftData!")
        } catch {
            print("Failed to save servers to SwiftData: \(error)")
        }
    }
}

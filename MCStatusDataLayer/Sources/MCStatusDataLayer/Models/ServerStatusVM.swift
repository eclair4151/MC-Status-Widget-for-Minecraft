import SwiftUI
import SwiftData

public enum LoadingStatus: String {
    case Loading, Finished
}

@Observable
public class ServerStatusVM: Identifiable, Hashable {
    public static func == (lhs: ServerStatusVM, rhs: ServerStatusVM) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    public let server: SavedMinecraftServer
    
    public var status: ServerStatus?
    
    public var loadingStatus = LoadingStatus.Loading
    public var serverIcon = UIImage()
    private var modelContext: ModelContext
    
    public init(modelContext: ModelContext, server: SavedMinecraftServer, status: ServerStatus? = nil) {
        self.server = server
        self.status = status
        self.modelContext = modelContext
        loadIcon()
    }
    
    public func reloadData(config: ServerCheckerConfig) {
        loadingStatus = .Loading
        
        Task {
            // DONT DO THIS, LET USER PASS IN FUNCTION WHICH WILL RELOAD DATA TO ALLOW REUSE IN WATCH
            let statusResult = await ServerStatusChecker.checkServer(server: server, config: config)
            print("Got result from status checker")
            
            self.status = statusResult
            // i need this but it crashes everything
            
            loadIcon()
            
            Task.detached { @MainActor in
                self.loadingStatus = .Finished
                
                if !statusResult.favIcon.isEmpty {
                    self.server.serverIcon = statusResult.favIcon
                    
                    print("Going to insert updated model")
                    self.modelContext.insert(self.server)
                    //                    print("inserted updated model")
                    
                    do {
                        // Try to save
                        //                        print("Going to save updated model")
                        
                        try self.modelContext.save()
                    } catch {
                        // We couldn't save :(
                        print(error.localizedDescription)
                    }
                    
                    print("Saved server icon to DB")
                }
            }
        }
    }
    
    public func getUserSampleText() -> String {
        guard let status else {
            return ""
        }
        
        return status.playerSample.map(\.name).joined(separator: ", ")
    }
    
    public func getPlayerCountPercentage() -> CGFloat {
        guard let status, status.maxPlayerCount > 0 else {
            return 0
        }
        
        let playerCount = status.onlinePlayerCount
        return CGFloat(playerCount) / CGFloat(status.maxPlayerCount)
    }
    
    public func getServerAddressToPing() -> String {
        if !server.srvServerUrl.isEmpty {
            server.srvServerUrl
        } else {
            server.serverUrl
        }
    }
    
    public func hasSRVRecord() -> Bool {
        guard !server.srvServerUrl.isEmpty && server.srvServerPort != 0 else {
            return false
        }
        
        if server.srvServerUrl == server.serverUrl && server.srvServerPort == server.serverPort {
            return false
        }
        
        return true
    }
    
    public func loadIcon() {
        var base64Icon = ""
        
        if let status, status.favIcon != "" {
            base64Icon = status.favIcon
        } else {
            base64Icon = server.serverIcon
        }
        
        guard !base64Icon.isEmpty else {
            if let defaultIcon = UIImage(named: "DefaultIcon") {
                self.serverIcon =  defaultIcon
            }
            
            return
        }
        
        if let decodedImage = ImageHelper.convertFavIconString(favIcon: base64Icon) {
            self.serverIcon =  decodedImage
        }
    }
    
    public func getMcHeadsUrl(uuid: String) -> String{
        "https://mc-heads.net/avatar/" + uuid + "/90"
    }
}

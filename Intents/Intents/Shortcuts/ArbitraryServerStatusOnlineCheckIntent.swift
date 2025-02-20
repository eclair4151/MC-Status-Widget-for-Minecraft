import AppIntents
import MCStatusDataLayer

struct ArbitraryServerStatusOnlineCheckIntent: AppIntent {
    static var title: LocalizedStringResource = "Arbitrary Minecraft Server Status Check"
    
    static var description =
    IntentDescription("Checks the status of an arbitrary Minecraft Server, and returns the server status which contains the player count, player sample, MOTD and Online Status, which can be either \"Online\",\"Offline\", or \"Unknown\" if the device if not connected to the internet or another error occurs", searchKeywords: ["Minecraft","server","status","check","query","lookup","MC"], resultValueName: "Minecraft Server Status")
    
    @Parameter(title: "Server Type")
    var serverType: ShortCutsServerType
    
    @Parameter(title: "Server Address/IP")
    var serverAddress: String
    
    @Parameter(title: "Server Port (Optional)")
    var serverPort: Int?
    
    func perform() async throws -> some ProvidesDialog & IntentResult & ReturnsValue<ServerStatusEntity>{
        let convertedServerType: ServerType = switch serverType {
        case .java: .Java
        case .bedrock: .Bedrock
        }
        
        let container = SwiftDataHelper.getModelContainter()
        
        // do something about this port shit
        let port = if let serverPort {
            serverPort
        } else if convertedServerType == .Java {
            25565
        } else {
            19132
        }
        
        let tempServer = SavedMinecraftServer.initialize(id: UUID(), serverType: convertedServerType, name: "", serverUrl: serverAddress, serverPort: port)
        
        // need to change this if we are on watch!!
        let status = await ServerStatusChecker.checkServer(tempServer)
        
        print("container:" + container.schema.debugDescription)
        
        let res = ServerStatusEntity(serverId: UUID(), serversName: serverAddress, serverStatus: status)
        return .result(value: res, dialog: "\(String(localized: res.displayRepresentation.title))")
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Check online status for \(\.$serverType) server at \(\.$serverAddress) and port \(\.$serverPort)")
    }
}

enum ShortCutsServerType: String, AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Server Type"
    
    static var caseDisplayRepresentations: [ShortCutsServerType: DisplayRepresentation] = [
        .java: "Java",
        .bedrock: "Bedrock/MCPE",
    ]
    
    case java, bedrock
    
    static var typeDisplayName: LocalizedStringResource = "Server Type"
}

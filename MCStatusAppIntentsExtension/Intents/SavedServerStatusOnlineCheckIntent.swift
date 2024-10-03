//
//  SavedServerStatusOnlineCheckIntent.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/29/23.
//
//
import Foundation
import AppIntents
import MCStatusDataLayer



private func runServerStatusIntentCheck(serverEntity: SavedServerEntity?, dismabiguationCallback: @escaping ([SavedMinecraftServer]) async throws -> SavedServerEntity) async throws -> ServerStatusEntity {
    let container = SwiftDataHelper.getModelContainter()
          
    let refrencedServer: SavedMinecraftServer

    
    if let serverEnt = serverEntity {
        guard let serverLookup = await SwiftDataHelper.getSavedServerById(container: container, server_id: serverEnt.id) else {
            throw MCIntentError.DB_ID_MISSING
        }
        refrencedServer = serverLookup
    } else {
        let savedServers = await SwiftDataHelper.getSavedServers(container: container)
        
        if savedServers.isEmpty {
            throw MCIntentError.NO_SERVERS
        }
        
        else if savedServers.count == 1, let serverLookup = savedServers.first {
            refrencedServer = serverLookup
        } else {
            let serverEnt = try await dismabiguationCallback(savedServers)
            guard let serverLookup = await SwiftDataHelper.getSavedServerById(container: container, server_id: serverEnt.id) else {
                throw MCIntentError.DB_ID_MISSING
            }
            refrencedServer = serverLookup
        }
    }
    
    let checkerConfig = ServerCheckerConfig(sortUsers: UserDefaultHelper.sortUsersByName())

    // need to change this if we are on watch!!
    let status = await ServerStatusChecker.checkServer(server: refrencedServer, config: checkerConfig)
    
    print("container:" + container.schema.debugDescription)
    return ServerStatusEntity(serverId: UUID(), serversName: refrencedServer.name, serverStatus: status)
}


struct SavedServerStatusOnlineCheckIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Saved Minecraft Server Status Check"
    
    static var description =
    IntentDescription("Checks the status of a server saved in the app, and returns the server status which contains the player count, player sample, MOTD and Online Status, which can be either \"Online\",\"Offline\", or \"Unknown\" if the device if not connected to the internet or another error occurs", searchKeywords: ["Minecraft","server","status","check","query","lookup","MC"], resultValueName: "Minecraft Server Status")
    
    @Parameter(title: "Server")
    var serverEntity: SavedServerEntity?
    
    func perform() async throws -> some ProvidesDialog & IntentResult & ReturnsValue<ServerStatusEntity>{
        
        let res = try await runServerStatusIntentCheck(serverEntity: serverEntity) { savedServers in
            try await $serverEntity.requestDisambiguation(
                among: savedServers.map {
                    SavedServerEntity(id: $0.id, serverName: $0.name)
                },
                dialog: IntentDialog("Which server would you like to check the status of?")
            )
        }
        
        return .result(value: res, dialog: "\(String(localized: res.displayRepresentation.title))")
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Check server status for \(\.$serverEntity)")

    }
}


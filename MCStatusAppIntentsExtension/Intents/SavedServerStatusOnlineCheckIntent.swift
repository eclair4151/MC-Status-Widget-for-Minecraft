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

struct SavedServerStatusOnlineCheckIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Saved Minecraft Server Status Check"
    
    static var description =
    IntentDescription("Checks the status of a server saved in the app, and returns either \"Online\",\"Offline\", or \"Unknown\" if the device if not connected to the internet or another error occurs", searchKeywords: ["Minecraft","server","status","check","query","lookup","MC"], resultValueName: "Minecraft Server Status")
    
    @Parameter(title: "Server")
    var serverEntity: SavedServerEntity?
    
    func perform() async throws -> some ProvidesDialog & IntentResult & ReturnsValue<ServerStatusEntity>{
        
        let container = SwiftDataHelper.getModelContainter()
              
        let refrencedServer: SavedMinecraftServer

        
        if let serverEnt = self.serverEntity {
            // case 
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
                let serverEnt = try await $serverEntity.requestDisambiguation(
                    among: savedServers.map {
                        SavedServerEntity(id: $0.id, serverName: $0.name)
                    },
                    dialog: IntentDialog("Which server would you like to check the status of?")
                )
                guard let serverLookup = await SwiftDataHelper.getSavedServerById(container: container, server_id: serverEnt.id) else {
                    throw MCIntentError.DB_ID_MISSING
                }
                refrencedServer = serverLookup
            }
        }
        
       
        
        // need to change this if we are on watch!!
        let status = await ServerStatusChecker.checkServer(server: refrencedServer)
        
        print("container:" + container.schema.debugDescription)
        let res = ServerStatusEntity(serverName: refrencedServer.name, id: UUID())
        res.playerCount = status.onlinePlayerCount
        res.onlineStatus = status.status.rawValue

        return .result(value: res, dialog: "\(String(localized: res.displayRepresentation.title))")
    }
    
    
    static var parameterSummary: some ParameterSummary {
        Summary("Check server status for \(\.$serverEntity)")

    }
}

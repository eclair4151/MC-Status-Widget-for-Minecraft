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
        
        let serverEntityObj = if let serverEnt = self.serverEntity {
            serverEnt
        } else {
            try await $serverEntity.requestDisambiguation(
                among: await SwiftDataHelper.getSavedServers(container: container).map {
                    SavedServerEntity(id: $0.id, serverName: $0.name)
                },
                dialog: IntentDialog("Which server would you like to check the status of?")
            )
        }
        
        guard let server = await SwiftDataHelper.getSavedServerById(container: container, server_id: serverEntityObj.id) else {
            throw MCIntentError.DB_ID_MISSING
        }
        
        // need to change this if we are on watch!!
        let status = await ServerStatusChecker.checkServer(server: server)
        
        print("container:" + container.schema.debugDescription)
        let res = ServerStatusEntity(serverName: server.name, id: UUID())
        res.playerCount = status.onlinePlayerCount
        res.onlineStatus = status.status.rawValue

        return .result(value: res, dialog: "\(String(localized: res.displayRepresentation.title))")
    }
    
    
    static var parameterSummary: some ParameterSummary {
        Summary("Check server status for \(\.$serverEntity)")

    }
}

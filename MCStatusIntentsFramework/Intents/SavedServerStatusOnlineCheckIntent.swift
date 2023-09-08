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
        
    static var title: LocalizedStringResource = "MC Status Saved Server Online Check"
    
    static var description =
           IntentDescription("Checks the status of a server and returns either \"Online\",\"Offline\", or \"Unknown\" if the device if not connected to the internet or another error occurs")
    
    @Parameter(title: "Server")
    var server: SavedServerEntity
    
    func perform() async throws -> some IntentResult & ReturnsValue<String>{
        
        let container = SwiftDataHelper.getModelContainter()

        guard let server = await SwiftDataHelper.getSavedServerById(container: container, server_id: server.id) else {
            throw MCIntentError.DB_ID_MISSING
        }
       
        let status = await ServerStatusChecker.checkServer(server: server)
        
        print("container:" + container.schema.debugDescription)

        return .result(value: status.status.rawValue)//status.status.rawValue)
    }
}

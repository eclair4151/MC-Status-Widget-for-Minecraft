//
//  File.swift
//  MCStatusIntentsFramework
//
//  Created by Tomer Shemesh on 9/8/23.
//

import Foundation
import AppIntents
import MCStatusDataLayer

struct SavedServerStatusPlayerCountIntent: AppIntent {
        
    static var title: LocalizedStringResource = "MC Status Saved Server Player Count"
    
    static var description =
           IntentDescription("Returns the number of players currently on a saved server. Returns -1 if the server is offline, and -2 if the device if not connected to the internet or another error occurs")
    
    @Parameter(title: "Server")
    var server: SavedServerEntity
    
    func perform() async throws -> some IntentResult & ReturnsValue<Int>{
        
        let container = SwiftDataHelper.getModelContainter()

        guard let server = await SwiftDataHelper.getSavedServerById(container: container, server_id: server.id) else {
            throw MCIntentError.DB_ID_MISSING
        }
       
        let status = await ServerStatusChecker.checkServer(server: server)
        
        print("container:" + container.schema.debugDescription)

        switch status.status {
        case .Online:
            return .result(value: status.onlinePlayerCount)//status.status.rawValue)
        case .Offline:
            return .result(value: -1)
        case .Unknown:
            return .result(value: -2)
        }
    }
}

//
//  WatchServerStatusChecker.swift
//  MCStatusWatchApp Watch App
//
//  Created by Tomer Shemesh on 8/19/23.
//

import Foundation
class WatchServerStatusChecker {
    static func checkServersViaPhone(servers:[SavedMinecraftServer], connectivityProvider: ConnectivityProvider) async throws -> [(SavedMinecraftServer, ServerStatus)] {
        
        let messageRequest = WatchRequestMessage()
        messageRequest.servers = servers
        let encoder = JSONEncoder()

        let jsonData = try encoder.encode(messageRequest)
        
        // Convert the JSON data to a string
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw ServerStatusCheckerError.StatusUnparsable
        }
        
        
        let payload = ["request":jsonString]
       
        try await connectivityProvider.send(message: payload)

        return []
    }
    
    // if we are calling third party do it individually so we can show the responses as they come in
    static func checkServerViaWeb(server: SavedMinecraftServer) async -> ServerStatus {
        do {
            print("CALLING BACKUP SERVER")
            let res = try await WebServerStatusChecker.checkServer(serverUrl: server.serverUrl, serverPort: server.serverPort, serverType: server.serverType)
            res.source = Source.ThirdParty
            print("Got result from third part. Returning...")
            return res
        } catch {
            // if we arent able to connect to the minecraft server directly, nor are we able to connect to the 3rd party server
            // we arent online at all most likley. status is unknown (default value)
            print("ERROR DIRECT CONNECTING TO BACKUP SERVER: phone most likley not connected at all." + error.localizedDescription)
            return ServerStatus()
        }
    }
}

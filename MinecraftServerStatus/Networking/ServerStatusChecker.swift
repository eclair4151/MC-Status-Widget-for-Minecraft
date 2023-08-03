//
//  ServerStatusChecker.swift
//  MinecraftServerStatus
//
//  Created by Tomer Shemesh on 7/29/23.
//

import Foundation

//  "hub.manacube.com"
//let serverAddress = "zero.minr.org"
//let serverPort: UInt16 = 25565
func testCall() {
    
    
    
    
    
    
    
//    let statusCheckerTask = Task {
//        let server = SavedMinecraftServer()
//        server.serverUrl = "hub.manacube.com"
//        server.serverPort = 25565
//        let serverStatus = await ServerStatusChecker.checkServer(server: server)
//        print(serverStatus)
//    }
}


func parseMOTD(input: String) {
    
}

class ServerStatusChecker {
    static func checkServer(server: SavedMinecraftServer) async -> ServerStatus {
        do {
            //check if connected to internet?
            let statusChecker = ServerStatusCheckerFactory().getStatusChecker(server: server)
            let stringResult = try await statusChecker.checkServer()
            return try statusChecker.getParser().parseServerResponse(stringInput: stringResult)
        } catch {
           // handle the error here in some way
            // call backup! 
            return ServerStatus()
        }
    }
}

//factory to dynamically handles creating the correct status checker for bedrock vs java
class ServerStatusCheckerFactory {
    func getStatusChecker(server: SavedMinecraftServer) -> ServerStatusCheckerProtocol {
        switch server.serverType {
        case .Java:
            JavaServerStatusChecker(serverAddress: server.serverUrl, port: server.serverPort)
        case .Bedrock:
            BedrockServerStatusChecker(serverAddress: server.serverUrl, port: server.serverPort)
        }
    }
}

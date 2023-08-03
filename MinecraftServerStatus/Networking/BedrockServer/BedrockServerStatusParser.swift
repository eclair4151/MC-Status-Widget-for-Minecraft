//
//  BedrockServerStatusParser.swift
//  MinecraftServerStatus
//
//  Created by Tomer Shemesh on 8/2/23.
//

import Foundation

class BedrockServerStatusParser: ServerStatusParserProtocol {
    static func parseServerResponse(stringInput: String) throws -> ServerStatus {
        let dataParts = stringInput.split(separator: ";")
        //[edition, motdLine1, protocolVersion, version, onlinePlayers, maxPlayers, serverID, motdLine2, gameMode, gameModeID, portIPv4, portIPv6]

//        guard dataParts.count > 7 else {
//            // throw error
//        }
//
//        //convert data
//        let serverStatus = ServerStatus()
//        serverStatus.setDescriptionString(description: dataParts[1] + "  |  " + dataParts[7])
//        let players = Players()
//        players.max = Int(dataParts[5]) ?? 0
//        players.online = Int(dataParts[4]) ?? 0
//        players.sample = []
//
//        serverStatus.players = players
//
//        let version = Version()
//        version.name = String(dataParts[3])
//        serverStatus.version = version
        return ServerStatus()
    }
}

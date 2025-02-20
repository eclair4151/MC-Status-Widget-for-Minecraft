//
//  WebServerStatusParser.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 8/6/23.
//

import Foundation

class WebServerStatusParser {
    static func parseServerResponse(input: WebJavaServerStatusResponse) throws -> ServerStatus {
        let status = ServerStatus()
        
        if let motdString = input.motd?.raw {
            status.description = FormattedMOTD(messageSections: JavaServerStatusParser.parseJavaMOTD(input: motdString))
        }
        
        if let iconString = input.icon {
            status.favIcon = iconString
        }
        
        if let players = input.players {
            status.maxPlayerCount = players.max
            status.onlinePlayerCount = players.online
            status.playerSample = players.list.map {
                return Player(name: $0.name_clean)
            }
        }
        
        if let versionString = input.version?.name_clean {
            status.version = versionString
        }
        
        status.status = if (input.online) {
            Status.Online
        } else {
            Status.Offline
        }
        return status
    }
    
    static func parseServerResponse(input: WebBedrockServerStatusResponse) throws -> ServerStatus {
        let status = ServerStatus()
        
        if let motdString = input.motd?.raw {
            status.description = FormattedMOTD(messageSections: BedrockServerStatusParser.parseBedrockMOTD(input: motdString))
        }
        
        if let players = input.players {
            status.maxPlayerCount = players.max
            status.onlinePlayerCount = players.online
        }
        
        if let versionString = input.version?.name {
            status.version = versionString
        }
        
        status.status = if (input.online) {
            Status.Online
        } else {
            Status.Offline
        }
        return status
    }
}

import Foundation

class WebServerStatusParser {
    static func parseServerResponse(input: WebJavaServerStatusResponse, config: ServerCheckerConfig?) throws -> ServerStatus {
        let status = ServerStatus()
        
        if let motdString = input.motd?.raw {
            status.description = FormattedMOTD(
                messageSections: JavaServerStatusParser.parseJavaMOTD(motdString)
            )
        }
        
        if let iconString = input.icon {
            status.favIcon = iconString
        }
        
        if let players = input.players {
            status.maxPlayerCount = players.max
            status.onlinePlayerCount = players.online
            
            status.playerSample = players.list.map {
                return Player(
                    name: $0.name_clean,
                    uuid: $0.uuid
                )
            }
        }
        
        // sort users if needed
        if config?.sortUsers ?? false {
            status.sortUsers()
        }
        
        if let versionString = input.version?.name_clean {
            status.version = versionString
        }
        
        status.status = if input.online {
            OnlineStatus.online
        } else {
            OnlineStatus.offline
        }
        
        return status
    }
    
    static func parseServerResponse(input: WebBedrockServerStatusResponse, config: ServerCheckerConfig?) throws -> ServerStatus {
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
        
        status.status = if input.online {
            OnlineStatus.online
        } else {
            OnlineStatus.offline
        }
        
        return status
    }
}

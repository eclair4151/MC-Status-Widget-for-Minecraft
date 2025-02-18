import Foundation

class WebBedrockServerStatusResponse: Decodable {
    let online: Bool
    let version: WebBedrockResponseVersion?
    let players: WebBedrockResponsePlayers?
    let motd: WebBedrockResponseMOTD?
}

class WebBedrockResponseVersion: Decodable {
    let name: String
}

class WebBedrockResponsePlayers: Decodable {
    let online: Int
    let max: Int
}

class WebBedrockResponseMOTD: Decodable {
    let raw: String
}

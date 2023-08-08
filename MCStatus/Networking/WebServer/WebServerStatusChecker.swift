//
//  WebServerChecker.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 8/6/23.
//

import Foundation

// this class is used to call the 3rd party web api, and ask them for information, in the case we are unable to connect directly.
class WebServerStatusChecker {
    static let API_URL = "https://api.mcstatus.io/v2/status/"
    
    static func checkServer(serverUrl: String, serverPort: Int, serverType: ServerType) async throws -> ServerStatus {
        var urlString = WebServerStatusChecker.API_URL
        if serverType == .Java {
            urlString += "java/"
        } else {
            urlString += "bedrock/"
        }
        
        urlString += serverUrl + ":" + String(serverPort)
        
        let url = URL(string: urlString)!
        let urlSession = URLSession.shared

        let (data, response) = try await urlSession.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            if (response as? HTTPURLResponse)?.statusCode == 400 {
                // if the backup server returns a 400, then we address we supplied is invalid, so the server is offline.
                let status = ServerStatus()
                status.status = .Offline
                return status
            } else {
                throw ServerStatusCheckerError.DeviceNotConnected
            }
        }

        if serverType == .Java {
            let decodedObj = try JSONDecoder().decode(WebJavaServerStatusResponse.self, from: data)
            return try WebServerStatusParser.parseServerResponse(input: decodedObj)
        } else {
            let decodedObj = try JSONDecoder().decode(WebBedrockServerStatusResponse.self, from: data)
            return try WebServerStatusParser.parseServerResponse(input: decodedObj)
        }
        
    }
}

import Foundation

// Class for calling 3rd party web API when direct connection fails
public class WebServerStatusChecker {
    static let API_URL = "https://api.mcstatus.io/v2/status"
    static let timeout = 4
    
    public static func checkServer(serverUrl: String, serverPort: Int, serverType: ServerType, config: ServerCheckerConfig?) async throws -> ServerStatus {
        var urlString = WebServerStatusChecker.API_URL
        if serverType == .Java {
            urlString += "java/"
        } else {
            urlString += "bedrock/"
        }
        
        urlString += serverUrl + ":" + String(serverPort) + "?timeout=" + String(timeout)
        
        let url = URL(string: urlString)!
        let urlSession = URLSession.shared
        
        let (data, response) = try await urlSession.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            if (response as? HTTPURLResponse)?.statusCode == 400 {
                // if the backup server returns a 400, then we address we supplied is invalid, so the server is offline
                let status = ServerStatus()
                status.status = .offline
                
                return status
            } else {
                throw ServerStatusCheckerError.DeviceNotConnected
            }
        }
        
        if serverType == .Java {
            let decodedObj = try JSONDecoder().decode(WebJavaServerStatusResponse.self, from: data)
            
            return try WebServerStatusParser.parseServerResponse(
                input: decodedObj,
                config: config
            )
        } else {
            let decodedObj = try JSONDecoder().decode(WebBedrockServerStatusResponse.self, from: data)
            
            return try WebServerStatusParser.parseServerResponse(
                input: decodedObj,
                config: config
            )
        }
    }
}

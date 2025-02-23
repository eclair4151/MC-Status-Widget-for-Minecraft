import Foundation

public class DirectServerStatusChecker {
    public static func checkServer(
        url: String,
        port: Int,
        type: ServerType,
        config: ServerCheckerConfig?
    ) async throws -> ServerStatus {
        let statusChecker = ServerStatusCheckerFactory().getStatusChecker(
            url: url,
            port: port,
            type: type
        )
        
        let stringResult = try await statusChecker.checkServer()
        
        print(stringResult)
        
        let result = try statusChecker.getParser().parseServerResponse(
            stringInput: stringResult,
            config: config
        )
        
        print("Successful connection and parsing, returning result")
        
        return result
    }
}

// Factory to dynamically handles creating the correct status checker for bedrock vs java
public class ServerStatusCheckerFactory {
    public func getStatusChecker(
        url: String,
        port: Int,
        type: ServerType
    ) -> ServerStatusCheckerProtocol {
        switch type {
        case .Java:
            JavaServerStatusChecker(serverAddress: url, port: port)
            
        case .Bedrock:
            BedrockServerStatusChecker(serverAddress: url, port: port)
        }
    }
}

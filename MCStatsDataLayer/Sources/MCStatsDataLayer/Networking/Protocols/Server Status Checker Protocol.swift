import Foundation

public protocol ServerStatusCheckerProtocol {
    init(address: String, port: Int)
    
    func checkServer() async throws -> String
    func getParser() -> ServerStatusParserProtocol.Type
}

public protocol ServerStatusParserProtocol {
    static func parseServerResponse(stringInput: String, config: ServerCheckerConfig?) throws -> ServerStatus
}

public enum ServerStatusCheckerError: Error {
    case DeviceNotConnected,
         ServerUnreachable,
         StatusUnparsable,
         InvalidPort,
         QueryBlocked
}

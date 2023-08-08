//
//  ServerStatusCheckerProtocol.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 7/29/23.
//

import Foundation

protocol ServerStatusCheckerProtocol {
    init(serverAddress: String, port: Int)
    
    func checkServer() async throws -> String
    func getParser() -> ServerStatusParserProtocol.Type
}


protocol ServerStatusParserProtocol {
    static func parseServerResponse(stringInput: String) throws -> ServerStatus
}


enum ServerStatusCheckerError: Error {
    case DeviceNotConnected
    case ServerUnreachable
    case StatusUnparsable
}




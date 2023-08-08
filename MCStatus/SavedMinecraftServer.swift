//
//  SavedMinecraftServer.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 7/30/23.
//

import Foundation

enum ServerType: Codable {
    case Java
    case Bedrock
}

public class SavedMinecraftServer: Codable {
    var name = ""
    var serverUrl = ""
    var serverPort = -1
    var srvServerUrl = ""
    var srvServerPort = -1
    var serverIcon = ""
    var order = 9999999
    var serverType = ServerType.Java
}

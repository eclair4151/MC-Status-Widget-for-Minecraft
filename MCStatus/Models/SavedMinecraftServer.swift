//
//  SavedMinecraftServer.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 7/30/23.
//

import Foundation
import SwiftData


enum ServerType: Codable {
    case Java
    case Bedrock
}

@Model
class SavedMinecraftServer: Identifiable {
    var id: UUID?
    var name:String?
    var serverUrl:String?
    var serverPort:Int?
    var srvServerUrl:String?
    var srvServerPort:Int?
    var serverIcon:String?
    var displayOrder:Int?
    var serverType: ServerType?
    
    init(id:UUID, serverType: ServerType, name: String, serverUrl: String, serverPort: Int, srvServerUrl: String = "", srvServerPort: Int = 1, serverIcon: String = "", displayOrder: Int = 0) {
        self.id = id
        self.name = name
        self.serverUrl = serverUrl
        self.serverPort = serverPort
        self.srvServerUrl = srvServerUrl
        self.srvServerPort = srvServerPort
        self.serverIcon = serverIcon
        self.displayOrder = displayOrder
        self.serverType = serverType
    }
}

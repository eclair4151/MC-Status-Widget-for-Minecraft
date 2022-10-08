//
//  SavedServer.swift
//  MinecraftServerStatus
//
//  Created by Tomer on 6/2/18.
//  Copyright © 2018 ShemeshApps. All rights reserved.
//

import Foundation
import RealmSwift

public class ServerType {
    static let SERVER_TYPE_JAVA = 0
    static let SERVER_TYPE_BEDROCK = 1
    static let SERVER_TYPE_JAVA_REALMS = 2
    static let SERVER_TYPE_BEDROCK_REALMS = 3
}


//server model for the database
public class SavedServer: Object, Codable {
    
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var serverUrl = ""
    @objc dynamic var serverIcon = ""
    @objc dynamic var order = 100
    @objc dynamic var showInWidget = false
    @objc dynamic var serverType = ServerType.SERVER_TYPE_JAVA
    
    
}

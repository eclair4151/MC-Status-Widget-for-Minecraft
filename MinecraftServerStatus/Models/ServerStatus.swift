//
//  ServerStatus.swift
//  MinecraftServerStatus
//
//  Created by Tomer Shemesh on 5/11/20.
//  Copyright © 2020 ShemeshApps. All rights reserved.
//

import Foundation

enum Status: Int, Codable {
    case Online, Offline, Unknown
}

public class ServerStatus: Codable {
    var description: Description? = nil
    var players: Players? = nil
    var version: Version? = nil
    var favicon: String? = nil
    var status: Status! = Status.Unknown
    
    init(status: Status) {
        self.status = status
    }
}


class Description: Codable {
    var text: String?
    var extra: [DescriptionExtra]?
}

class Players: Codable {
    var max: Int!
    var online: Int!
    var sample: [UserSample]?
}

class Version: Codable {
    var name: String!
}

class UserSample: Codable {
    var name: String!
}

class DescriptionExtra: Codable {
    var text: String?
}

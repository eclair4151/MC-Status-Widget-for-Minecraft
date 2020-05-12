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
    let text: String?
    let extra: [DescriptionExtra]?
}

class Players: Codable {
    let max: Int!
    let online: Int!
    let sample: [UserSample]?
}

class Version: Codable {
    let name: String!
}

class UserSample: Codable {
    let name: String!
    let id: String!
}

class DescriptionExtra: Codable {
    let text: String?
}

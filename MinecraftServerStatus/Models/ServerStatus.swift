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
    let description: Description? = nil
    let players: Players? = nil
    let version: Version? = nil
    let favicon: String? = nil
    var status = Status.Unknown
    
    init(status: Status) {
        self.status = status
    }
    //init() {}
}


class Description: Codable {
    let text: String!
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

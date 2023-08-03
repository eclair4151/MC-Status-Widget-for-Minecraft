//
//  ServerStatus.swift
//  MinecraftServerStatus
//
//  Created by Tomer Shemesh on 5/11/20.
//  Copyright © 2020 ShemeshApps. All rights reserved.
//

import Foundation


public class JavaServerStatusResponse: Decodable {
    var description: Description? = nil
    var players: Players? = nil
    var version: Version? = nil
    var favicon: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case description = "description"
        case players = "players"
        case version = "version"
        case favicon = "favicon"
    }

    // We need a custom decoder inside this response, because different servers return different data formats, so we need to handle this dynamically
    // Sometimes the description is a string, while other times, its a description sub object with additional info inside.
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // first check it its a regular string, if so, load it into the description object to keep everything consistent
        if let strDesc = try? container.decode(String.self, forKey: .description) {
            let desc = Description()
            desc.text = strDesc
            self.description = desc
        } else if let objDesc = try? container.decode(Description.self, forKey: .description) {
            self.description = objDesc
        }
        
        self.players = try? container.decode(Players.self, forKey: .players)
        self.version = try? container.decode(Version.self, forKey: .version)
        self.favicon = try? container.decode(String.self, forKey: .favicon)
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

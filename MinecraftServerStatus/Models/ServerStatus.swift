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

public class ServerStatus: Decodable {
    var description: String? = nil
    var players: Players? = nil
    var version: Version? = nil
    var favicon: String? = nil
    var status: Status! = Status.Unknown
    
    init(status: Status) {
        self.status = status
    }
    
    
    enum CodingKeys: String, CodingKey {
        case description = "description"
        case players = "players"
        case version = "version"
        case favicon = "favicon"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var strDesc = try? container.decode(String.self, forKey: .description)
        if strDesc == nil {
            let objDesc = try? container.decode(Description.self, forKey: .description)
            if let des = objDesc {
                if (!(des.text?.isEmpty ?? true)) {
                    strDesc = des.text
                } else if let extras = des.extra, extras.count > 0 {
                    strDesc = extras.reduce("", { previousString, nextExtra in
                        return previousString + (nextExtra.text ?? "")
                    })
                }
            }
        }
        strDesc = strDesc?.replacingOccurrences(of: "\n", with: " ")
        strDesc = strDesc?.replacingOccurrences(of: "§.", with: "", options: .regularExpression)
        print("test")
        self.description = strDesc?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.players = try? container.decode(Players.self, forKey: .players)
        self.version = try? container.decode(Version.self, forKey: .version)
        self.favicon = try? container.decode(String.self, forKey: .favicon)

        self.status = .Unknown
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

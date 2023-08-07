//
//  ServerStatus.swift
//  MinecraftServerStatus
//
//  Created by Tomer Shemesh on 5/11/20.
//  Copyright © 2020 ShemeshApps. All rights reserved.
//

import Foundation


public class JavaServerStatusResponse: Decodable {
    var description: JavaMOTDDescriptionSection? = nil
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
            let desc = JavaMOTDDescriptionSection()
            desc.text = strDesc
            self.description = desc
        } else if let objDesc = try? container.decode([String].self, forKey: .description) { //then check if it is a regular string array (very rare but valid)
            let desc = JavaMOTDDescriptionSection()
            desc.text = objDesc.joined()
            self.description = desc
        } else if let objDesc = try? container.decode(JavaMOTDDescriptionSection.self, forKey: .description) { //finally anything remaining should be the description object
            self.description = objDesc
        } else {
            print("FAILED TO PARSE: " + (try! decoder.singleValueContainer().decode(String.self)))
        }
        
        self.players = try? container.decode(Players.self, forKey: .players)
        self.version = try? container.decode(Version.self, forKey: .version)
        self.favicon = try? container.decode(String.self, forKey: .favicon)
    }
}

// this needs to be refactored, as this currently does not support regular string string array's nested inside the extra instead of being a description object, which is techinically valid, although i've never seen it. Should be handled either way.
// IE dynmic decoding of the extra to check the same as above. is it a string, string array, or a desc object?
class JavaMOTDDescriptionSection: Codable {
    var text: String?
    var color: String?
    var extra: [JavaMOTDDescriptionSection]?
    var bold:Bool?
    var italic:Bool?
    var underlined:Bool?
    var strikethrough:Bool?
    var obfuscated:Bool?
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



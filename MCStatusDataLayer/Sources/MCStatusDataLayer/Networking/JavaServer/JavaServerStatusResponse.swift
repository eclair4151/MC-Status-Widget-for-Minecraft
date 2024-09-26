//
//  ServerStatus.swift
//  MCStatus
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
            print("FAILED TO PARSE INCOMING SERVER JSON")
            throw ServerStatusCheckerError.StatusUnparsable
        }
        
        
        self.players = try? container.decode(Players.self, forKey: .players)
        self.version = try? container.decode(Version.self, forKey: .version)
        self.favicon = try? container.decode(String.self, forKey: .favicon)
    }
}

// this needs to be refactored, as this currently does not support regular string string array's nested inside the extra instead of being a description object, which is techinically valid, although i've never seen it. Should be handled either way.
// IE dynmic decoding of the extra to check the same as above. is it a string, string array, or a desc object?
class JavaMOTDDescriptionSection: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case text = "text"
        case color = "color"
        case extra = "extra"
        case bold = "bold"
        case italic = "italic"
        case underlined = "underlined"
        case strikethrough = "strikethrough"
        case obfuscated = "obfuscated"

    }
    
    var text: String?
    var color: String?
    var extra: [JavaMOTDDescriptionSection]?
    var bold:Bool?
    var italic:Bool?
    var underlined:Bool?
    var strikethrough:Bool?
    var obfuscated:Bool?
    
    public init() {
        
    }
    
    public required init(from decoder: Decoder) throws {
        // first check if this object is a string itself
        let strContainer = try decoder.singleValueContainer()
        
        if let rawText = try? strContainer.decode(String.self) {
            self.text = rawText
            return
        }


        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // first check extra it its a regular string, if so, load it into the text object to keep everything consistent
        if let strExtra = try? container.decode(String.self, forKey: .extra) {
            let extra = JavaMOTDDescriptionSection()
            extra.text = strExtra
            self.extra = [extra]
        } else if let strArr = try? container.decode([String].self, forKey: .extra) { //then check if it is a regular string array (very rare but valid)
            let extra = JavaMOTDDescriptionSection()
            extra.text = strArr.joined(separator: " ")
            self.extra = [extra]
            
        } else if let objDesc = try? container.decode([JavaMOTDDescriptionSection].self, forKey: .extra) { //finally anything remaining should be the description object
            self.extra = objDesc
        }
        // otherwise there is no extra, just the regular properties, continue parsing as normal.

        
        self.text = try? container.decode(String.self, forKey: .text)
        self.color = try? container.decode(String.self, forKey: .color)
        self.bold = try? container.decode(Bool.self, forKey: .bold)
        self.italic = try? container.decode(Bool.self, forKey: .italic)
        self.underlined = try? container.decode(Bool.self, forKey: .underlined)
        self.strikethrough = try? container.decode(Bool.self, forKey: .strikethrough)
        self.obfuscated = try? container.decode(Bool.self, forKey: .obfuscated)
    }
}

class Players: Decodable {
    var max: Int!
    var online: Int!
    var sample: [UserSample]?
}

class Version: Decodable {
    var name: String!
}

class UserSample: Decodable {
    var name: String!
}



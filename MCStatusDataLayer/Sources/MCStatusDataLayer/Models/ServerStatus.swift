//
//  ServerStatus.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 7/30/23.
//

import Foundation

public enum Status: String, Codable {
    case Online, Offline, Unknown
}

public enum Source: Codable {
    case Direct, CachedSRV, UpdatedSRV, ThirdParty
}

@Observable
public class ServerStatus: Identifiable, Codable {
    public var source: Source?
    public var description: FormattedMOTD?
    public var status = Status.Unknown
    public var maxPlayerCount = 0
    public var onlinePlayerCount = 0
    public var playerSample:[Player] = []
    public var version = ""
    public var favIcon = ""
    
    
    public func getDisplayText() -> String {
        return status.rawValue + " " + String(onlinePlayerCount) + "/" + String(maxPlayerCount)
    }
    
    public init() {
        
    }
}


public class Player: Codable {
    public init(name: String) {
        self.name = name
    }
    public var name = ""
}

public class FormattedMOTD: Codable {
    public init(messageSections: [FormattedMOTDSection]) {
        self.messageSections = messageSections
    }
    public var messageSections:[FormattedMOTDSection] = []
}


public class FormattedMOTDSection: Codable {
    
    public init () {
        
    }
    
    public init (text: String) {
        self.text = text
    }
    
    public var text = ""
    public var color = ""
    public var formatters:Set<MOTDFormatter> = []
}


public enum MOTDFormatter: Codable {
    case Bold
    case Italic
    case Underline
    case Strikethrough
    case Obfuscated
    case Reset
}

public enum MOTDColor: String {
    case Black = "#000000"
    case DarkBlue = "#0000AA"
    case DarkGreen = "#00AA00"
    case DarkAqua = "#00AAAA"
    case DarkRed = "#AA0000"
    case DarkPurple = "#AA00AA"
    case Gold = "#FFAA00"
    case Gray = "#AAAAAA"
    case DarkGray = "#555555"
    case Blue = "#5555FF"
    case Green = "#55FF55"
    case Aqua = "#55FFFF"
    case Red = "#FF5555"
    case LightPurple = "#FF55FF"
    case Yellow = "#FFFF55"
    case White = "#FFFFFF"
    case MinecoinGold = "#DDD605"
    case MaterialQuartz = "#E3D4D1"
    case MaterialIron = "#CECACA"
    case MaterialNetherite = "#443A3B"
    case MaterialRedstone = "#971607"
    case MaterialCopper = "#B4684D"
    case MaterialGold = "#DEB12D"
    case MaterialEmerald = "#47A036"
    case MaterialDiamond = "#2CBAA8"
    case MaterialLapis = "#21497B"
    case MaterialAmethyst = "#9A5CC6"
}

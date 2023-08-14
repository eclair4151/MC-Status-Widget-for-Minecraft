//
//  ServerStatus.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 7/30/23.
//

import Foundation

enum Status: String {
    case Online, Offline, Unknown
}

enum Source: Codable {
    case Direct, CachedSRV, UpdatedSRV, ThirdParty
}

@Observable
class ServerStatus: Identifiable {
    var source: Source?
    var description: FormattedMOTD?
    var status = Status.Unknown
    var maxPlayerCount = 0
    var onlinePlayerCount = 0
    var playerSample:[Player] = []
    var version = ""
    var favIcon = ""
    
    
    func getDisplayText() -> String {
        return status.rawValue + " " + String(onlinePlayerCount) + "/" + String(maxPlayerCount)
    }
}


class Player {
    init(name: String) {
        self.name = name
    }
    var name = ""
}

class FormattedMOTD {
    init(messageSections: [FormattedMOTDSection]) {
        self.messageSections = messageSections
    }
    var messageSections:[FormattedMOTDSection] = []
}


class FormattedMOTDSection {
    
    init () {
        
    }
    
    init (text: String) {
        self.text = text
    }
    
    var text = ""
    var color = ""
    var formatters:Set<MOTDFormatter> = []
}


enum MOTDFormatter {
    case Bold
    case Italic
    case Underline
    case Strikethrough
    case Obfuscated
    case Reset
}

enum MOTDColor: String {
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

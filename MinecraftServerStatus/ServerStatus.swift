//
//  ServerStatus.swift
//  MinecraftServerStatus
//
//  Created by Tomer Shemesh on 7/30/23.
//

import Foundation



enum Status: Codable {
    case Online, Offline, Unknown
}


class ServerStatus {
    var description: FormattedMOTD?
    var status = Status.Unknown
    
}



class FormattedMOTD {
    var messageSections:[FormattedMOTDSection] = []
}


class FormattedMOTDSection {
    var text = ""
    var color = MOTDColor.White
    var bold = false
    var italic = false
    var underline = false
    var strikethrough = false
    var obfuscated = false
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
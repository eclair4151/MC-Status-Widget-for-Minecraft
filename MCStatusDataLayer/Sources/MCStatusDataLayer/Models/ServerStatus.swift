import Foundation

public enum OnlineStatus: String, Codable {
    case Online, Offline, Unknown
}

public enum Source: Codable {
    case Direct, CachedSRV, UpdatedSRV, ThirdParty
}

@Observable
public class ServerStatus: Identifiable, Codable {
    public var source: Source?
    public var description: FormattedMOTD?
    public var status = OnlineStatus.Unknown
    public var maxPlayerCount = 0
    public var onlinePlayerCount = 0
    public var playerSample: [Player] = []
    public var version = ""
    public var favIcon = ""
    
    public func getDisplayText() -> String {
        status.rawValue + " - " + String(onlinePlayerCount) + "/" + String(maxPlayerCount)
    }
    
    public func getWatchDisplayText() -> String {
        if status == .Online {
            String(onlinePlayerCount) + "/" + String(maxPlayerCount)
        } else {
            status.rawValue
        }
    }
    
    public func sortUsers() {
        playerSample.sort {
            $0.name.lowercased() < $1.name.lowercased()
        }
    }
    
    public init() {
        
    }
}

public class Player: Codable, Identifiable {
    public init(name: String, uuid: String) {
        self.name = name
        self.uuid = uuid
    }
    
    public var name = ""
    public var uuid = ""
}

public class FormattedMOTD: Codable {
    public init(messageSections: [FormattedMOTDSection]) {
        self.messageSections = messageSections
    }
    
    public var messageSections:[FormattedMOTDSection] = []
    
    public func getRawText() -> String {
        messageSections.map(\.text).joined()
    }
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
    case Bold,
         Italic,
         Underline,
         Strikethrough,
         Obfuscated,
         Reset
}

public enum MOTDColor: String {
    case Black = "#000000",
         DarkBlue = "#0000AA",
         DarkGreen = "#00AA00",
         DarkAqua = "#00AAAA",
         DarkRed = "#AA0000",
         DarkPurple = "#AA00AA",
         Gold = "#FFAA00",
         Gray = "#AAAAAA",
         DarkGray = "#555555",
         Blue = "#5555FF",
         Green = "#55FF55",
         Aqua = "#55FFFF",
         Red = "#FF5555",
         LightPurple = "#FF55FF",
         Yellow = "#FFFF55",
         White = "#FFFFFF",
         MinecoinGold = "#DDD605",
         MaterialQuartz = "#E3D4D1",
         MaterialIron = "#CECACA",
         MaterialNetherite = "#443A3B",
         MaterialRedstone = "#971607",
         MaterialCopper = "#B4684D",
         MaterialGold = "#DEB12D",
         MaterialEmerald = "#47A036",
         MaterialDiamond = "#2CBAA8",
         MaterialLapis = "#21497B",
         MaterialAmethyst = "#9A5CC6"
}

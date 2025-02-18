import SwiftUI
import MCStatusDataLayer

enum WidgetViewType {
    case Default, Preview, Unconfigured
}

extension WidgetEntryVM {
    init(serverName: String, status: ServerStatus, lastUpdated: String, serverIcon: UIImage, theme: Theme) {
        self.lastUpdated = lastUpdated
        
        self.icon = serverIcon
        self.serverName = serverName
        
        if status.status == OnlineStatus.Online {
            self.statusIcon = nil
            self.progressString = "\(status.onlinePlayerCount) / \(status.maxPlayerCount)"
            
            // Avoid potential for divide by 0
            if status.maxPlayerCount == 0 {
                self.progressValue = 0
            } else {
                self.progressValue = Float(status.onlinePlayerCount) / Float(status.maxPlayerCount)
            }
            
            self.playersMax = status.maxPlayerCount
            self.playersOnline = status.onlinePlayerCount
            
            self.progressStringAlpha = 1
            self.progressStringSize = 23
            
        } else if status.status == OnlineStatus.Offline {
            self.statusIcon = "multiply.circle.fill"
            self.progressString = "-- / --"
            self.progressValue = 0
            self.playersMax = 0
            self.playersOnline = 0
            self.progressStringAlpha = 0.5
            self.progressStringSize = 23
            
        } else {
            self.statusIcon = "questionmark.circle.fill"
            self.progressString = "No Connection"
            self.progressValue = 0
            self.playersMax = 0
            self.playersOnline = 0
            self.progressStringAlpha = 0.65
            self.progressStringSize = 15
        }
        
        self.playersString = ""
        
        if status.playerSample.count > 0 {
            var playerList = status.playerSample
            
            if UserDefaultHelper.shared.get(for: .sortUsersByName, defaultValue: true) {
                playerList.sort {
                    $0.name.lowercased() < $1.name.lowercased()
                }
            }
            
            var playerListString = playerList.map(\.name).joined(separator: ", ")
            
            if status.onlinePlayerCount > status.playerSample.count {
                playerListString += ",..."
            }
            
            self.playersString = playerListString
        }
        
        switch theme {
        case .blue:
            self.bgColor = Color.widgetBackgroundBlue
            
        case .green:
            self.bgColor = Color.widgetBackgroundGreen
            
        case .red:
            self.bgColor = Color.widgetBackgroundRed
            
        default: break
        }
    }
    
    init() {
        self.lastUpdated = "2m ago"
        self.icon = UIImage(named: "DefaultIcon")!
        self.statusIcon = nil
        self.playersString = "Player 1, Player 2, Player 3"
        self.serverName = "My Server"
        self.progressString = "3 / 20"
        self.progressValue = 0.15
        self.progressStringAlpha = 1
        self.progressStringSize = 23
        self.playersOnline = 3
        self.playersMax = 20
    }
    
    mutating func setServerIcon(base64Data: String) {
        print("Decoding base64 image")
        
        self.icon = ImageHelper.convertFavIconString(base64Data) ?? UIImage(named: "DefaultIcon")!
    }
    
    mutating func setForUnconfiguredView() {
        self.serverName = "Edit Widget"
        self.progressString = "-- / --"
        self.lastUpdated = "now"
        self.progressValue = 0
        self.playersOnline = 0
        self.playersMax = 20
        self.playersString = ""
        self.viewType = .Unconfigured
    }
}

public struct WidgetEntryVM {
    var lastUpdated: String
    var icon: UIImage
    var statusIcon: String?
    var serverName: String
    var progressString: String
    var progressStringAlpha: Double
    var progressStringSize: Int
    var progressValue: Float
    var playersOnline: Int
    var playersMax: Int
    var playersString: String
    var bgColor: Color = .widgetBackground
    var viewType = WidgetViewType.Default
}

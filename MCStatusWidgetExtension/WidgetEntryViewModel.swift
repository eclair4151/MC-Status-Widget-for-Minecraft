//
//  WidgetEntryViewModel.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 10/10/24.
//


import Foundation
import SwiftUI
import MCStatusDataLayer


enum WidgetViewType {
    case Default, Preview, Unconfigured
}



extension WidgetEntryViewModel {
    init(serverName:String, status: ServerStatus, lastUpdated: String, serverIcon: UIImage, theme: Theme) {
        self.lastUpdated = lastUpdated
        
        //print(status.favicon)
        self.icon = serverIcon
//        self.icon = UIImage()
        self.serverName = serverName
        
//        if(status.status == OnlineStatus.Online) {
//            self.statusIcon = nil
//            self.progressString = "\(status.onlinePlayerCount) / \(status.maxPlayerCount)"
//            self.progressValue = Float(status.players?.online ?? 0) / Float(status.players?.max ?? 20)
//            self.progressStringAlpha = 1.0
//            self.progressStringSize = 23
//        } else if (status.status == OnlineStatus.Offline) {
//            self.statusIcon = "multiply.circle.fill"
//            self.progressString = "-- / --"
//            self.progressValue = 0
//            self.progressStringAlpha = 0.5
//            self.progressStringSize = 23
//        } else {
//            self.statusIcon = "questionmark.circle.fill"
//            self.progressString = "No Connection"
//            self.progressValue = 0
//            self.progressStringAlpha = 0.65
//            self.progressStringSize = 15
//        }
//        
//        self.playersString = ""
//        if let players = status.players, let playerList = players.sample, playerList.count > 0 {
//            var playerListString = playerList.map{ $0.name }.joined(separator: ", ")
//            if players.online > playerList.count {
//                playerListString += ",..."
//            }
//            self.playersString = playerListString
//        }
//        
//        switch theme {
//            case .blue:
//                self.bgColor = Color.widgetBackgroundBlue
//            case .green:
//                self.bgColor = Color.widgetBackgroundGreen
//            case .red:
//                self.bgColor = Color.widgetBackgroundRed
//            default: break
//        }
        
        
        // TEMP HACK
        self.lastUpdated = "2m ago"
        self.icon = UIImage(named: "DefaultIcon")!
        self.statusIcon = nil
        self.playersString = "Player 1, Player 2, Player 3"
        self.serverName = "My Server"
        self.progressString = "3 / 20"
        self.progressValue = 0.15
        self.progressStringAlpha = 1.0
        self.progressStringSize = 23
    }

    init() {
        self.lastUpdated = "2m ago"
        self.icon = UIImage(named: "DefaultIcon")!
        self.statusIcon = nil
        self.playersString = "Player 1, Player 2, Player 3"
        self.serverName = "My Server"
        self.progressString = "3 / 20"
        self.progressValue = 0.15
        self.progressStringAlpha = 1.0
        self.progressStringSize = 23
    }
    
    mutating func setServerIcon(base64Data: String) {
        print("Decoding base64 image")
        
        self.icon = ImageHelper.convertFavIconString(favIcon: base64Data) ?? UIImage(named: "DefaultIcon")!
    }
}



public struct WidgetEntryViewModel {
    
    var lastUpdated: String
    var icon: UIImage
    var statusIcon: String?
    var serverName: String
    var progressString: String
    var progressStringAlpha: Double
    var progressStringSize: Int
    var progressValue: Float
    var playersString: String
    var bgColor: Color = Color.brown
    var viewType = WidgetViewType.Default
}

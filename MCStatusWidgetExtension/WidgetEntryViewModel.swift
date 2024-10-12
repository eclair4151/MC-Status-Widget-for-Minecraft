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
        
        self.icon = serverIcon
        self.serverName = serverName
        
        if(status.status == OnlineStatus.Online) {
            self.statusIcon = nil
            self.progressString = "\(status.onlinePlayerCount) / \(status.maxPlayerCount)"
            if status.maxPlayerCount == 0 { //avoid potential for divide by 0
                self.progressValue = 0
            } else {
                self.progressValue = Float(status.onlinePlayerCount) / Float(status.maxPlayerCount)
            }
            
            self.progressStringAlpha = 1.0
            self.progressStringSize = 23
        } else if (status.status == OnlineStatus.Offline) {
            self.statusIcon = "multiply.circle.fill"
            self.progressString = "-- / --"
            self.progressValue = 0
            self.progressStringAlpha = 0.5
            self.progressStringSize = 23
        } else {
            self.statusIcon = "questionmark.circle.fill"
            self.progressString = "No Connection"
            self.progressValue = 0
            self.progressStringAlpha = 0.65
            self.progressStringSize = 15
        }
        
        self.playersString = ""
        if status.playerSample.count > 0 {
            var playerList = status.playerSample
            if UserDefaultHelper.sortUsersByName() {
                playerList.sort {
                    $0.name.lowercased() < $1.name.lowercased()
                }
            }
            var playerListString = playerList.map{ $0.name }.joined(separator: ", ")
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
        self.progressStringAlpha = 1.0
        self.progressStringSize = 23
    }
    
    mutating func setServerIcon(base64Data: String) {
        print("Decoding base64 image")
        
        self.icon = ImageHelper.convertFavIconString(favIcon: base64Data) ?? UIImage(named: "DefaultIcon")!
    }
    
    mutating func setForUnconfiguredView() {
        self.serverName = "Edit Widget"
        self.progressString = "-- / --"
        self.lastUpdated = "now"
        self.progressValue = 0
        self.playersString = ""
        self.viewType = .Unconfigured
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
    var bgColor: Color = Color.widgetBackground
    var viewType = WidgetViewType.Default
}

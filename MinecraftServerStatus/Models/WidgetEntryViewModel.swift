//
//  WidgetEntryViewModel.swift
//  MinecraftServerStatus
//
//  Created by Tomer on 1/25/21.
//  Copyright © 2021 ShemeshApps. All rights reserved.
//

import Foundation
import SwiftUI



extension WidgetEntryViewModel {
    init(serverName:String, status: ServerStatus, lastUpdated: String, serverIcon: UIImage, theme: Theme) {
        self.lastUpdated = lastUpdated
        print("testwoooo")
        //print(status.favicon)
       self.icon = serverIcon
        //self.icon = UIImage(named: "DefaultIcon")!
        self.serverName = serverName
        
        if(status.status == Status.Online) {
            self.statusIcon = nil
            self.progressString = "\(status.players?.online ?? 0) / \(status.players?.max ?? 20)"
            self.progressValue = Float(status.players?.online ?? 0) / Float(status.players?.max ?? 20)
            self.progressStringAlpha = 1.0
            self.progressStringSize = 23
        } else if (status.status == Status.Offline) {
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
        if let players = status.players, let playerList = players.sample, playerList.count > 0 {
            var playerListString = playerList.map{ $0.name }.joined(separator: ", ")
            if players.online > playerList.count {
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
    var bgColor: Color = Color.widgetBackground
    var isDefaultView = false
}

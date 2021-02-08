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
    init(serverName:String, status: ServerStatus, lastUpdated: String) {
        self.lastUpdated = lastUpdated
        self.icon = ImageHelper.convertFavIconString(favIcon: status.favicon) ?? UIImage(named: "DefaultIcon")!
        self.serverName = serverName
        self.progressString = "\(status.players?.online ?? 0) / \(status.players?.max ?? 20)"
        self.progressValue = Float(status.players?.online ?? 0) / Float(status.players?.max ?? 20)

        if(status.status == Status.Online) {
            self.statusIcon = "checkmark.circle.fill"
            self.statusColor = "CheckColor"
        } else if (status.status == Status.Offline) {
            self.statusIcon = "multiply.circle.fill"
            self.statusColor = "CrossColor"
        } else {
            self.statusIcon = "questionmark.circle.fill"
            self.statusColor = "UnknownColor"
        }
        
        self.playersString = ""
        if let players = status.players, let playerList = players.sample, playerList.count > 0 {
            var playerListString = playerList.map{ $0.name }.joined(separator: ", ")
            if players.online > playerList.count {
                playerListString += ",...       "
            }
            self.playersString = playerListString
        }
    }

    init() {
        self.lastUpdated = "2m ago"
        self.icon = UIImage(named: "DefaultIcon")!
        self.statusIcon = "questionmark.circle.fill"
        self.statusColor = "UnknownColor"
        self.playersString = "Player 1, Player 2, Player 3"
        self.serverName = "My Server"
        self.progressString = "0 / 20"
        self.progressValue = 0.0
    }
    
    mutating func setServerIcon(base64Data: String) {
        self.icon = ImageHelper.convertFavIconString(favIcon: base64Data) ?? UIImage(named: "DefaultIcon")!
    }
}

public struct WidgetEntryViewModel {
    var lastUpdated: String
    var icon: UIImage
    var statusIcon: String
    var statusColor: String
    var serverName: String
    var progressString: String
    var progressValue: Float
    var playersString: String
}

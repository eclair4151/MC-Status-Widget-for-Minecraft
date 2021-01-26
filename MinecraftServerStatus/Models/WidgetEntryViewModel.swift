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
        self.progressString = "\(status.players?.online ?? 0)/\(status.players?.max ?? 20)"
        self.progressValue = Float(status.players?.online ?? 0) / Float(status.players?.max ?? 20)

        if(status.status == Status.Online) {
            self.statusIcon = "checkmark.circle.fill"
            self.statusColor = "CheckColor"
        } else {
            self.statusIcon = "multiply.circle.fill"
            self.statusColor = "CrossColor"
        }

        self.playersString = ""//status.players?.sample
    }

    init() {
        self.lastUpdated = "3m ago"
        self.icon = UIImage(named: "DefaultIcon")!
        self.statusIcon = "checkmark.circle.fill"
        self.statusColor = "CheckColor"
        self.playersString = ""
        self.serverName = "Tomer's Server woo"
        self.progressString = "3/20"
        self.progressValue = 0.15
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
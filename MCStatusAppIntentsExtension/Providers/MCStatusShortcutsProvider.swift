//
//  MCStatusShortcutsProvider.swift
//  MCStatusAppIntentsExtension
//
//  Created by Tomer Shemesh on 9/9/23.
//

import Foundation
import AppIntents

public struct MCStatusShortcutsProvider: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent:SavedServerStatusOnlineCheckIntent(),
            phrases: [
                "Check the \(.applicationName) of my Minecraft server",
                "What's the \(.applicationName) of my Minecraft server",
                "Check the \(.applicationName) of my server",
                "What's the \(.applicationName) of my server",
                "What's the \(.applicationName) of \(\.$serverEntity)",
                "Can you check the \(.applicationName) of \(\.$serverEntity)",
                "Can you check the server \(.applicationName) of \(\.$serverEntity)",
                "What's the current \(.applicationName) of \(\.$serverEntity)",
                "Check the \(.applicationName) of \(\.$serverEntity) for me",
                "Check \(\.$serverEntity) server \(.applicationName) for me",
                "Check \(\.$serverEntity) \(.applicationName) for me"
            ],
            shortTitle: "Server Status",
            systemImageName: "rectangle.­connected.­to.­line.­below"
        )
    }    
}


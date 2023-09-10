//
//  MCStatusShortcutsProvider.swift
//  MCStatusIntentsFramework
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
                "Check the \(.applicationName)",
                "Check the \(.applicationName) for \(\.$serverEntity)",
            ],
            shortTitle: "Server Status",
            systemImageName: "rectangle.­connected.­to.­line.­below"
        )
    }
    
    
}

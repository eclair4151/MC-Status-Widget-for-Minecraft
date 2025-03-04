import AppIntents

public struct ShortcutsProvider: AppShortcutsProvider {
    public static var shortcutTileColor: ShortcutTileColor = .blue
    
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SavedServerStatusOnlineCheckIntent(),
            phrases: [
                "Check the \(.applicationName) of my server",
                "Check the \(.applicationName) of my Minecraft server",
                "What's the \(.applicationName) of my server",
                "What's the \(.applicationName) of my Minecraft server",
                "What's the \(.applicationName) of \(\.$serverEntity)",
                "Check the \(.applicationName) of \(\.$serverEntity)",
                "Check \(\.$serverEntity)'s \(.applicationName) for me"
            ],
            shortTitle: "Check Server Status",
            systemImageName: "rectangle.connected.to.line.below"
        )
    }
}

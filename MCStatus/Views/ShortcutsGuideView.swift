import SwiftUI
import AppIntents

struct ShortcutsGuideView: View {
    private let shortcutImages = [
        "shortcuts1", "shortcuts2", "shortcuts3",
        "shortcuts4", "shortcuts5", "shortcuts6"
    ]
    
    private let shortcutDescriptions = [
        "To create a custom shortcut, open the shortcut app, create a new shortcut, and search for MC Status.\n The \"Saved Minecraft Server Status Check\" lets you select a specific server from your saved list in the app. The arbitrary server check shortcut allows you to pass in a custom URL and port to check any server on the fly.",
        "You can select which server you want to check the status of in the shortcut. By default the shortcut will show a popup with the server status and player count. To disable this, click the drop down arrow and disable \"Show When Run\"",
        "The resulting shortcut object represents the server status, and can be used however you need. Once you select the Server Status variable, you can pick  which property of the server status you want to use in your further shortcuts.",
        "Online status can be \"Online\", \"Offline\", or \"Unknown\" if your phone is not connected.",
        "Player Count and Max Player Count are the number and max allowed number of players online. These can be used to create automations based on the number of players online",
        "Player Sample is a comma separated string of 12 random players online (for servers which support it). This can be used to check if certain users are online. (Only works reliably when there are 12 or less players online)"
    ]
    
    var body: some View {
        Form {
            // Overview Section
            Section {
                ShortcutsLink()
                    .shortcutsLinkStyle(.automaticOutline)
                
                Text("""
                With Shortcuts, you can quickly check the status of your Minecraft servers without even opening the app. Use the built in shortcuts to show the current status and player count, or create custom shortcuts using the server's online status, current player count, player sample, and more.
                """)
                .padding(.vertical, 5)
            } header: {
                Text("Overview of Shortcuts")
                    .title2(.bold)
                    .padding(.bottom, 5)
            }
            .headerProminence(.increased)
            
            // Shortcut Steps Section
            ForEach(0..<shortcutImages.count, id: \.self) { index in
                Section {
                    Text(shortcutDescriptions[index])
                        .foregroundColor(.primary)
                        .padding(.bottom, 5)
                    
                    Image(shortcutImages[index])
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                }
            }
        }
        .navigationTitle("Shortcuts")
        .background(Color(.systemGroupedBackground))
    }
}

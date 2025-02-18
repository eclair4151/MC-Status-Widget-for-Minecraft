import SwiftUI

// General Settings Sub-View
struct GeneralSettingsView: View {
    @AppStorage(UserDefaultHelper.Key.iCloudEnabled.rawValue)        private var toggle1 = true
    @AppStorage(UserDefaultHelper.Key.showUsersOnHomesreen.rawValue) private var toggle2 = true
    @AppStorage(UserDefaultHelper.Key.sortUsersByName.rawValue)      private var toggle3 = true
    @AppStorage(UserDefaultHelper.Key.openToSpecificServer.rawValue) private var toggle4 = true
    
    var body: some View {
        Form {
            Toggle(isOn: $toggle1) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Enable iCloud Syncing")
                    
                    Text("Sync your server list across all devices.")
                        .footnote()
                        .foregroundColor(.gray)
                }
            }
            
            // Show users on homescreen Toggle
            Toggle(isOn: $toggle2) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Show users on server list")
                    
                    Text("Show users in each row under the progress bar on the main server list")
                        .footnote()
                        .foregroundColor(.gray)
                }
            }
            
            // Sort users by name Toggle
            Toggle(isOn: $toggle3) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sort users alphabetically")
                    
                    Text("Show users sorted alphabetically instead of randomly")
                        .footnote()
                        .foregroundColor(.gray)
                }
            }
            
            Toggle(isOn: $toggle4) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Widget opens directly to server")
                    
                    Text("Tapping the widget will open the app directly to that server. Otherwise it will open the server list.")
                        .footnote()
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("General Settings")
    }
}

#Preview {
    GeneralSettingsView()
}

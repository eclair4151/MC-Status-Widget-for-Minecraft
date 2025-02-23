import SwiftUI

// General Settings Sub-View
struct GeneralSettings: View {
    @AppStorage(UserDefaultHelper.Key.iCloudEnabled.rawValue)        private var icloudSync = true
    @AppStorage(UserDefaultHelper.Key.showUsersOnHomesreen.rawValue) private var playersInServerList = true
    @AppStorage(UserDefaultHelper.Key.sortUsersByName.rawValue)      private var sortPlayersByName = true
    @AppStorage(UserDefaultHelper.Key.openToSpecificServer.rawValue) private var openToSpecificServer = true
    
    var body: some View {
        Form {
            Toggle(isOn: $icloudSync) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("iCloud Sync")
                    
                    Text("Sync your server list across all devices")
                        .footnote()
                        .foregroundColor(.gray)
                }
            }
            
            Toggle(isOn: $playersInServerList) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Show players on server list")
                    
                    Text("Show players in each row under the progress bar on the main server list")
                        .footnote()
                        .foregroundColor(.gray)
                }
            }
            
            Toggle(isOn: $sortPlayersByName) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sort players alphabetically")
                    
                    Text("Show players sorted alphabetically instead of randomly")
                        .footnote()
                        .foregroundColor(.gray)
                }
            }
#if !os(tvOS)
            Section("Widgets") {
                Toggle(isOn: $openToSpecificServer) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Widgets open directly to server")
                        
                        Text("Tapping the widget will open the app directly to that server. Otherwise it will open the server list")
                            .footnote()
                            .foregroundColor(.gray)
                    }
                }
            }
#endif
        }
        .navigationTitle("General Settings")
    }
}

#Preview {
    GeneralSettings()
}

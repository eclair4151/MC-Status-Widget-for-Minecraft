import SwiftUI

struct SettingsView: View {
    private let reloadServers: () -> Void
    
    init(reloadServers: @escaping () -> Void = {}) {
        self.reloadServers = reloadServers
    }
    
    var body: some View {
        List {
            DebugSettings {
                reloadServers()
            }
        }
    }
}

#Preview {
    SettingsView()
}

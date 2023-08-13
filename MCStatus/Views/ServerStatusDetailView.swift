//
//  ServerDetailView.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/9/23.
//

import SwiftUI

struct ServerStatusDetailView: View {
    var serverStatusViewModel: ServerStatusViewModel
    
    var body: some View {
        Text("\(serverStatusViewModel.server.name!)")
        Text("\(serverStatusViewModel.server.serverUrl! + ":" + String(serverStatusViewModel.server.serverPort!))")
        Text("\("Version: " + (serverStatusViewModel.status?.version ?? "Loading"))")
        Text("Online Players: " + String(serverStatusViewModel.status?.onlinePlayerCount ?? 0))
    }
}

#Preview {
    ServerStatusDetailView(serverStatusViewModel: ServerStatusViewModel(server: SavedMinecraftServer(id:UUID() ,serverType: .Java, name: "Hodor", serverUrl: "zero.minr.org", serverPort: 255)))
}




//
//  WatchServerDetailScreen.swift
//  MCStatusWatchApp Watch App
//
//  Created by Tomer Shemesh on 10/7/24.
//

import SwiftUI
import MCStatusDataLayer
import NukeUI

struct WatchServerDetailScreen: View {
    @State var serverStatusViewModel: ServerStatusViewModel

    var body: some View {
        let playerList = serverStatusViewModel.status?.playerSample ?? []
        let onlinePlayerCount = serverStatusViewModel.status?.onlinePlayerCount ?? 0
        if (serverStatusViewModel.status?.status == .Offline) {
            Text("Server is offline")
        } else if (serverStatusViewModel.server.serverType == .Bedrock) {
            Text("Bedrock servers do not support player lists.")
        } else if (onlinePlayerCount == 0) {
            Text("No players online")
        } else if playerList.isEmpty && onlinePlayerCount > 0 {
            Text("This server has disabled player lists.")
        }
        List {
            Section {
                ForEach(playerList) { player in
                    HStack() {
                        let imageUrl = URL(string: serverStatusViewModel.getMcHeadsUrl(uuid: player.uuid))
                        LazyImage(url: imageUrl) { state in
                            if let image = state.image {
                                image.resizable().scaledToFill()
                            } else if state.error != nil {
                                Color.serverIconBackground
                            } else {
                                ZStack {
                                    Color.serverIconBackground
                                    ProgressView().opacity(0.3)
                                }
                            }
                        }
                        .cornerRadius(2)
                            .frame(width: 25, height: 25)
                            .padding([.trailing], 3)
                            
                        Text(player.name).lineLimit(1)
                    }
                    
                }
            } footer: {
                let playerSampleCount = serverStatusViewModel.status?.playerSample.count ?? 0
                let onlinePlayersCount = serverStatusViewModel.status?.onlinePlayerCount ?? 0
                
                if (playerSampleCount > 0 && playerSampleCount < onlinePlayersCount) {
                    Text("*Player list limited to \(playerSampleCount) users by server").frame(maxWidth: .infinity, alignment: .center)
                }
            }
            
        }.navigationTitle(serverStatusViewModel.server.name)
    }
}

//#Preview {
//    WatchServerDetailScreen()
//}

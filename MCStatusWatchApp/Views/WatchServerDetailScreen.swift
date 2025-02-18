import SwiftUI
import MCStatusDataLayer
import NukeUI

struct WatchServerDetailScreen: View {
    @State var serverStatusVM: ServerStatusVM
    
    var body: some View {
        let playerList = serverStatusVM.status?.playerSample ?? []
        let onlinePlayerCount = serverStatusVM.status?.onlinePlayerCount ?? 0
        
        if serverStatusVM.status?.status == .Offline {
            Text("Server is offline")
            
        } else if serverStatusVM.server.serverType == .Bedrock {
            Text("Bedrock servers do not support player lists.")
            
        } else if onlinePlayerCount == 0 {
            Text("No players online")
            
        } else if playerList.isEmpty && onlinePlayerCount > 0 {
            Text("This server has disabled player lists.")
        }
        
        List {
            Section {
                ForEach(playerList) { player in
                    HStack {
                        let imageUrl = URL(string: serverStatusVM.getMcHeadsUrl(uuid: player.uuid))
                        
                        LazyImage(url: imageUrl) { state in
                            if let image = state.image {
                                image.resizable().scaledToFit()
                            } else if state.error != nil {
                                Color.serverIconBackground
                            } else {
                                ZStack {
                                    Color.serverIconBackground
                                    
                                    ProgressView()
                                        .opacity(0.3)
                                }
                            }
                        }
                        .cornerRadius(2)
                        .frame(width: 25, height: 25)
                        .padding(.trailing, 3)
                        
                        Text(player.name)
                            .lineLimit(1)
                    }
                }
            } footer: {
                let playerSampleCount = serverStatusVM.status?.playerSample.count ?? 0
                let onlinePlayersCount = serverStatusVM.status?.onlinePlayerCount ?? 0
                
                if playerSampleCount > 0 && playerSampleCount < onlinePlayersCount {
                    Text("*Player list limited to \(playerSampleCount) users by server")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle(serverStatusVM.server.name)
    }
}

//#Preview {
//    WatchServerDetailScreen()
//}

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
        List {
            ForEach(playerList) { player in
                HStack() {
                    let imageUrl = URL(string: serverStatusViewModel.getMcHeadsUrl(uuid: player.uuid))
//                                let imageUrl = URL(string: "https://httpbin.org/delay/10")
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
        }
    }
}

//#Preview {
//    WatchServerDetailScreen()
//}

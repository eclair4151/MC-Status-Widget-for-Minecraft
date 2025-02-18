import SwiftUI
import MCStatusDataLayer
import NukeUI

struct PlayerCard: View {
    @Environment(ServerStatusVM.self) private var vm
    
    private let player: Player
    
    init(_ player: Player) {
        self.player = player
    }
    
    var body: some View {
        HStack(spacing: 0) {
            let imageUrl = URL(string: vm.getMcHeadsUrl(uuid: player.uuid))
            // let imageUrl = URL(string: "https://httpbin.org/delay/10")
            
            LazyImage(url: imageUrl) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFit()
                    
                } else if state.error != nil {
                    Color.placeholderGrey
                    
                } else {
                    ZStack {
                        Color.placeholderGrey
                        
                        ProgressView()
                            .opacity(0.3)
                    }
                }
            }
            .cornerRadius(3)
            .frame(width: 30, height: 30)
            .padding(.trailing, 16)
            
            Text(player.name)
        }
        .padding(.vertical, 10)
        .listRowInsets(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
        .toolbar {
            Button {
                UIPasteboard.general.string = player.name
            } label: {
                Label("Copy Nickname", systemImage: "document.on.document")
            }
        }
    }
}

#Preview {
    PlayerCard(.init(
        name: "Preview",
        uuid: "Preview"
    ))
}

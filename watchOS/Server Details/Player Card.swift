import SwiftUI
import NukeUI
import MCStatsDataLayer

struct PlayerCard: View {
    @State private var vm: ServerStatusVM
    private let player: Player
    
    init(_ player: Player, vm: ServerStatusVM) {
        self.player = player
        self.vm = vm
    }
    
    var body: some View {
        let imageUrl = URL(string: vm.getMcHeadsUrl(player.uuid))
        
        HStack {
            LazyImage(url: imageUrl) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFit()
                    
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
}

//#Preview {
//    PlayerCard()
//}

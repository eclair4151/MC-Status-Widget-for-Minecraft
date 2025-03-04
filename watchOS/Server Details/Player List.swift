import SwiftUI
import NukeUI
import MCStatsDataLayer

struct PlayerList: View {
    @Environment(ServerStatusVM.self) private var vm
    
    var body: some View {
        let playerList = vm.status?.playerSample ?? []
        
        ForEach(playerList) { player in
            PlayerCard(player)
        }
    }
}

//#Preview {
//    PlayerList()
//        .environment(ServerStatusVM())
//}

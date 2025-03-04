import SwiftUI
import NukeUI
import MCStatsDataLayer

struct PlayerList: View {
    @State private var vm: ServerStatusVM
    
    init(_ vm: ServerStatusVM) {
        self.vm = vm
    }
    
    var body: some View {
        let playerList = vm.status?.playerSample ?? []
        
        ForEach(playerList) { player in
            PlayerCard(player, vm: vm)
        }
    }
}

//#Preview {
//    PlayerList()
//}

import SwiftUI
import MCStatsDataLayer

struct PlayerList: View {
    @Environment(ServerStatusVM.self) private var vm
    
    var body: some View {
        Section {
            ForEach(vm.status?.playerSample ?? []) { player in
                PlayerCard(player)
            }
        } footer: {
            let playerSampleCount = vm.status?.playerSample.count ?? 0
            let onlinePlayerCount = vm.status?.onlinePlayerCount ?? 0
            
            if playerSampleCount > 0 && playerSampleCount < onlinePlayerCount {
                Text("Player list limited to \(playerSampleCount) users by server")
            }
        }
    }
}

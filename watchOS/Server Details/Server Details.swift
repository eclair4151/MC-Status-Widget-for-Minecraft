import SwiftUI
import MCStatsDataLayer
import NukeUI

struct ServerDetails: View {
    @State private var vm: ServerStatusVM
    
    private var parentViewRefreshCallBack: () -> Void
    
    init(_ vm: ServerStatusVM, parentViewRefreshCallBack: @escaping () -> Void) {
        self.vm = vm
        self.parentViewRefreshCallBack = parentViewRefreshCallBack
    }
    
    @State private var sheetEdit = false
    
    var body: some View {
        let playerList = vm.status?.playerSample ?? []
        let onlinePlayerCount = vm.status?.onlinePlayerCount ?? 0
        
        List {
            MOTDView(vm.status)
            
            if vm.status?.status == .offline {
                Text("Server is offline")
                
            } else if vm.server.serverType == .Bedrock {
                Text("Bedrock servers do not support player lists")
                
            } else if onlinePlayerCount == 0 {
                Text("No players online")
                
            } else if playerList.isEmpty && onlinePlayerCount > 0 {
                Text("This server has disabled player lists")
            }
            
            Section {
                PlayerList()
                    .environment(vm)
            } footer: {
                let playerSampleCount = vm.status?.playerSample.count ?? 0
                
                if playerSampleCount > 0 && playerSampleCount < onlinePlayerCount {
                    Text("Player list limited to \(playerSampleCount) users by server")
                }
            }
            
            Section {
                Button {
                    sheetEdit = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .navigationTitle(vm.server.name)
        .sheet($sheetEdit) {
            NavigationStack {
                EditServerView(vm.server, isPresented: $sheetEdit) {
                    vm.reloadData(ConfigHelper.getServerCheckerConfig())
                    parentViewRefreshCallBack()
                }
            }
        }
    }
}

//#Preview {
//    ServerDetails()
//}

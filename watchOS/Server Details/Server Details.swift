import SwiftUI
import MCStatsDataLayer
import NukeUI

struct ServerDetails: View {
    @State var vm: ServerStatusVM
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var refresh: () -> Void
    
    init(_ vm: ServerStatusVM, refresh: @escaping () -> Void) {
        self.vm = vm
        self.refresh = refresh
    }
    
    @State private var sheetEdit = false
    @State private var alertDelete = false
    
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
            
            PlayerList()
            
            Section {
                Button {
                    sheetEdit = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    alertDelete = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(vm.server.name)
        .environment(vm)
        .alert("Delete Server?", isPresented: $alertDelete) {
            Button("Delete", role: .destructive) {
                deleteServer()
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .sheet($sheetEdit) {
            NavigationStack {
                EditServerView($vm.server) {
                    vm.reloadData(ConfigHelper.getServerCheckerConfig())
                    refresh()
                }
            }
        }
    }
}

//#Preview {
//    ServerDetails()
//}

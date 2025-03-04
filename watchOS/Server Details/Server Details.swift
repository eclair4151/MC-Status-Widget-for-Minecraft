import SwiftUI
import MCStatsDataLayer
import NukeUI

struct ServerDetails: View {
    @State private var vm: ServerStatusVM
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    private var parentViewRefreshCallBack: () -> Void
    
    init(_ vm: ServerStatusVM, parentViewRefreshCallBack: @escaping () -> Void) {
        self.vm = vm
        self.parentViewRefreshCallBack = parentViewRefreshCallBack
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
                
                Button(role: .destructive) {
                    alertDelete = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(vm.server.name)
        .alert("Delete Server?", isPresented: $alertDelete) {
            Button("Delete", role: .destructive) {
                deleteServer()
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .sheet($sheetEdit) {
            NavigationStack {
                EditServerView(vm.server, isPresented: $sheetEdit) {
                    vm.reloadData(ConfigHelper.getServerCheckerConfig())
                    parentViewRefreshCallBack()
                }
            }
        }
    }
    
    private func deleteServer() {
        modelContext.delete(vm.server)
        
        do {
            try modelContext.save()
        } catch {
            // Failures include issues such as an invalid unique constraint
            print(error.localizedDescription)
        }
        
        refreshAllWidgets()
        
        parentViewRefreshCallBack()
        dismiss()
    }
}

//#Preview {
//    ServerDetails()
//}

//
//  ServerDetailView.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/9/23.
//

import SwiftUI

struct ServerStatusDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var showingDeleteAlert = false
    @State var serverStatusViewModel: ServerStatusViewModel
    var parentViewRefreshCallBack: () -> Void
    
    
    var body: some View {
        ScrollView {
            Text("\(serverStatusViewModel.server.name!)")
            Text("\(serverStatusViewModel.server.serverUrl! + ":" + String(serverStatusViewModel.server.serverPort!))")
            Text("\("Version: " + (serverStatusViewModel.status?.version ?? "Loading"))")
            Text("Online Players: " + String(serverStatusViewModel.status?.onlinePlayerCount ?? 0))
        }.refreshable {
            serverStatusViewModel.reloadData()
        }.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button {
                        
                    } label: {
                        Text("Edit")
                    }
                    Button {
                        showingDeleteAlert = true
                    } label: {
                        Label("Add Item", systemImage: "trash")
                    }
                }
            }
        }.alert("Delete Server?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteServer()
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private func deleteServer() {
        modelContext.delete(serverStatusViewModel.server)
        do {
            // Try to save
            try modelContext.save()
        } catch {
            // We couldn't save :(
            // Failures include issues such as an invalid unique constraint
            print(error.localizedDescription)
        }
        parentViewRefreshCallBack()
        self.presentationMode.wrappedValue.dismiss()
    }
}

//#Preview {
//    ServerStatusDetailView(serverStatusViewModel: ServerStatusViewModel(server: SavedMinecraftServer(id:UUID() ,serverType: .Java, name: "Hodor", serverUrl: "zero.minr.org", serverPort: 255)))
//}




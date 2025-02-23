import SwiftUI
import SwiftData
import MCStatusDataLayer

struct DebugSettings: View {
    @Query private var servers: [SavedMinecraftServer]
    @Environment(\.modelContext) private var modelContext
    
    let reloadServers: () -> Void
    
    @State private var confirmDeleteAll = false
    
    var body: some View {
        Section("Debug") {
            Button {
                addTestServers()
            } label: {
                Label("Add test servers", systemImage: "plus")
            }
            
            Button(role: .destructive) {
                confirmDeleteAll = true
            } label: {
                Label("Delete all servers", systemImage: "trash")
                    .foregroundStyle(.red)
            }
            .confirmationDialog("Are you sure?", isPresented: $confirmDeleteAll) {
                Button("Delete all servers", role: .destructive) {
                    deleteAllServers()
                }
            }
        }
    }
    
    private func deleteAllServers() {
        for server in servers {
            modelContext.delete(server)
        }
        
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
        reloadServers()
    }
    
    
    private func addTestServers() {
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Insanity Craft", serverUrl: "join.insanitycraft.net", serverPort: 25565))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "OpBlocks", serverUrl: "hub.opblocks.com", serverPort: 25565))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Ace MC", serverUrl: "mc.acemc.co", serverPort: 25565))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Vanilla Realms", serverUrl: "mcs.vanillarealms.com", serverPort: 25565))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Earth MC", serverUrl: "org.earthmc.net", serverPort: 25565))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Zero's Server", serverUrl: "zero.minr.org", serverPort: 25565))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Rainy Day", serverUrl: "rainyday.gg", serverPort: 25565))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Harmony Server", serverUrl: "join.harmonyfallssmp.world", serverPort: 25565))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Bedrock, name: "Fade Cloud", serverUrl: "mp.fadecloud.com", serverPort: 19132))
        modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Bedrock, name: "MC Hub", serverUrl: "mps.mchub.com", serverPort: 19132))
        
        reloadServers()
    }
}

#Preview {
    DebugSettings {}
}

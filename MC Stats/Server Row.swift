import SwiftUI
import MCStatsDataLayer

struct ServerRow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    private var vm: ServerStatusVM
    
    init(_ vm: ServerStatusVM) {
        self.vm = vm
    }
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        @Bindable var vm = vm
        
        HStack {
#if os(macOS)
            Image(nsImage: vm.serverIcon)
                .serverIconStyle()
                .animation(.default, value: vm.serverIcon)
#else
            Image(uiImage: vm.serverIcon)
                .serverIconStyle()
                .animation(.default, value: vm.serverIcon)
#endif
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(vm.server.name)
                            .headline()
                            .foregroundColor(.primary)
                        
                        if let status = vm.status {
                            if status.status == .offline {
                                Text(status.status.rawValue.capitalized)
                                    .subheadline(.bold)
                                    .foregroundColor(.red)
                            } else {
                                Text(status.getDisplayText())
                                    .subheadline()
                                    .secondary()
                            }
                        } else if vm.loadingStatus == .Loading {
                            Text(vm.loadingStatus.rawValue)
                                .subheadline()
                                .secondary()
                        }
                    }
                    
                    Spacer()
                    
                    if vm.loadingStatus == .Loading {
                        ProgressView()
                            .padding(.trailing, 5)
                    }
                }
                
                if let status = vm.status, status.status != .offline {
                    CustomProgressView(progress: vm.getPlayerCountPercentage())
                        .frame(height: 8)
                }
                
                if UserDefaultsHelper.shared.get(for: .showUsersOnHomesreen, defaultValue: true) {
                    let sampletext = vm.getUserSampleText()
                    
                    if !sampletext.isEmpty {
                        Text(sampletext)
                            .footnote()
                            .secondary()
                            .padding(0)
                            .frame(height: 8)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }
        }
        .contextMenu {
            Button {
                showingEditSheet = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
#if !os(tvOS)
            let serverAddressString = vm.server.serverUrl + ":" + String(vm.server.serverPort)
            ShareLink(item: serverAddressString)
#endif
            Section {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .alert("Delete Server?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteServer()
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .sheet($showingEditSheet) {
            NavigationStack {
                EditServerView($vm.server) {
                    vm.reloadData(ConfigHelper.getServerCheckerConfig())
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
        dismiss()
    }
}

//#Preview {
////    ServerRowView(title: "test", subtitle: "subtitle")
////    let vm = ServerStatusVM(modelContext: , server: <#T##SavedMinecraftServer#>)
//}

fileprivate extension Image {
    func serverIconStyle() -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: 65, height: 65)
            .cornerRadius(8)
            .clipShape(.rect(cornerRadius: 8))
            .padding(.trailing, 5)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 3, y: 3)
    }
}

import SwiftUI
import MCStatusDataLayer

struct ServerRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    private var vm: ServerStatusVM
    
    init(_ vm: ServerStatusVM) {
        self.vm = vm
    }
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack {
            Image(uiImage: vm.serverIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 65, height: 65)
                .cornerRadius(8)
                .background(.serverIconBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "6e6e6e"), lineWidth: 3)
                }
                .clipShape(.rect(cornerRadius: 8))
                .padding(.trailing, 5)
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(vm.server.name)
                            .headline()
                            .foregroundColor(.primary)
                        
                        if let status = vm.status {
                            if status.status == .Offline {
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
                
                if let status = vm.status, status.status != .Offline {
                    CustomProgressView(progress: vm.getPlayerCountPercentage())
                        .frame(height: 8)
                }
                
                if UserDefaultHelper.shared.get(for: .showUsersOnHomesreen, defaultValue: true) {
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
            
            Section {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete Server", systemImage: "trash")
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
                EditServerView(vm.server, isPresented: $showingEditSheet) {
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
        
        self.presentationMode.wrappedValue.dismiss()
    }
}

//#Preview {
////    ServerRowView(title: "test", subtitle: "subtitle")
////    let vm = ServerStatusVM(modelContext: , server: <#T##SavedMinecraftServer#>)
//}

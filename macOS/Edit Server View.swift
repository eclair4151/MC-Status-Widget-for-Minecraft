import SwiftUI
import SwiftData
import MCStatsDataLayer

struct EditServerView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    private enum FocusedField {
        case serverName, serverAddress
    }
    
    @Binding var server: SavedMinecraftServer
    var refresh: () -> Void
    
    init(
        _ server: Binding<SavedMinecraftServer>,
        refresh: @escaping () -> Void = {}
    ) {
        _server = server
        self.refresh = refresh
    }
    
    @FocusState private var focusedField: FocusedField?
    
    @State var tempNameInput = ""
    @State var tempServerInput = ""
    @State var tempPortInput: Int? = nil
    @State var tempServerType = ServerType.Java
    
    @State var portLabelPromptText = "Port (Optional - Default 25565)"
    
    @State var showingInvalidUrlAlert = false
    @State var showingInvalidNameAlert = false
    @State var showingInvalidPortAlert = false
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.gray)
                        .headline()
                        .frame(width: 25, height: 25)
                    
                    Text("Server Type")
                    
                    Picker("", selection: $tempServerType) {
                        Text("Java Edition")
                            .tag(ServerType.Java)
                        
                        Text("Bedrock/MCPE")
                            .tag(ServerType.Bedrock)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: tempServerType) { _, newValue in
                        if newValue == .Java {
                            portLabelPromptText = "Port (Optional - Default 25565)"
                        } else if newValue == .Bedrock {
                            portLabelPromptText = "Port (Optional - Default 19132)"
                        }
                    }
                }
            }
            
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(.gray)
                    .headline()
                    .frame(width: 25, height: 25)
                
                TextField("Server Name", text: $tempNameInput, prompt: Text("Server Name"))
                    .submitLabel(.next)
                    .focused($focusedField, equals: .serverName)
                    .onSubmit {
                        focusedField = .serverAddress
                    }
            }
            
            HStack {
                Image(systemName: "rectangle.connected.to.line.below")
                    .foregroundColor(.gray)
                    .headline()
                    .frame(width: 25, height: 25)
                
                TextField("Server Address/IP", text: $tempServerInput, prompt: Text("Server Address/IP"))
                    .autocorrectionDisabled(true)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .serverAddress)
                    .onChange(of: tempServerInput) { _, newValue  in
                        extractPort(newValue)
                    }
            }
            
            HStack {
                Image(systemName: "number")
                    .foregroundColor(.gray)
                    .headline()
                    .frame(width: 25, height: 25)
                
                TextField(portLabelPromptText, value: $tempPortInput, formatter: NumberFormatter(), prompt: Text(portLabelPromptText))
                    .monospacedDigit()
            }
            
            Text("MC Stats is used for checking the status an existing server. It will not create, setup, or host a new server")
                .footnote()
                .secondary()
        }
        .frame(minHeight: 200)
        .navigationTitle("Start monitoring a server")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .destructive) {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveItem()
                }
                .disabled(saveDisabled())
            }
        }
        .onAppear {
            tempServerInput = server.serverUrl
            
            if server.serverPort != 0 {
                tempPortInput = server.serverPort
            }
            
            tempNameInput = server.name
            tempServerType = server.serverType
            focusedField = .serverName
        }
        .interactiveDismissDisabled(inputHasChanged())
        .alert("Invalid Server URL/IP Address", isPresented: $showingInvalidUrlAlert) {
            Button("OK") {}
        } message: {
            Text("Minecraft Server domains/ip addresses must be the root domain, and not contain any '/' or ':'")
        }
        .alert("Invalid Server Name", isPresented: $showingInvalidNameAlert) {
            Button("OK") {}
        }
        .alert("Invalid Port", isPresented: $showingInvalidPortAlert) {
            Button("OK") {}
        } message: {
            Text("Port must be a number between 0 and 65535")
        }
    }
}

#Preview {
    @Previewable @State var server = SavedMinecraftServer.initialize(
        id: UUID(),
        serverType: .Java,
        name: "",
        serverUrl: "",
        serverPort: 0,
        srvServerUrl: "",
        srvServerPort: 0,
        serverIcon: "",
        displayOrder: 0
    )
    
    NavigationStack {
        EditServerView($server)
    }
}

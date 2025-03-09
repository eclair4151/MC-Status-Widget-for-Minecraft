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
        Form {
            Section {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.gray)
                            .headline()
                            .frame(width: 25, height: 25)
                        
                        Picker("Server Type", selection: $tempServerType) {
                            Text("Java Edition")
                                .tag(ServerType.Java)
                            
                            Text("Bedrock/MCPE")
                                .tag(ServerType.Bedrock)
                        }
                    }
                    
                    .onChange(of: tempServerType) { _, newValue in
                        if newValue == .Java {
                            portLabelPromptText = "Port (Optional - Default 25565)"
                        } else if newValue == .Bedrock {
                            portLabelPromptText = "Port (Optional - Default 19132)"
                        }
                    }
                }
                
                TextField("Server Name", text: $tempNameInput, prompt: Text("Server Name"))
                    .textInputAutocapitalization(.words)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .serverName)
                    .onSubmit {
                        focusedField = .serverAddress
                    }
                
                TextField("Server Address/IP", text: $tempServerInput, prompt: Text("Server Address/IP"))
                    .autocorrectionDisabled(true)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .serverAddress)
                    .onChange(of: tempServerInput) { _, newValue  in
                        extractPort(newValue)
                    }
                
                TextField(portLabelPromptText, value: $tempPortInput, formatter: NumberFormatter(), prompt: Text(portLabelPromptText))
                    .monospacedDigit()
            } header: {
                Text("Start monitoring a server")
            } footer: {
                Text("MC Stats is used for checking the status an existing server. It will not create, setup, or host a new server")
            }
            .headerProminence(.increased)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveItem()
                }
                .disabled(saveDisabled())
            }
        }
        .onAppear {
            tempServerInput = server.serverUrl
            extractPort(server.serverUrl)
            
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

//#Preview {
//    EditServerView(server: $)
//}

import SwiftUI
import SwiftData
import MCStatsDataLayer

struct EditServerView: View {
    @Environment(\.modelContext) private var modelContext
    
    private enum FocusedField {
        case serverName, serverAddress
    }
    
    @State private var server: SavedMinecraftServer
    @Binding private var isPresented: Bool
    private var parentViewRefreshCallBack: () -> Void
    
    init(
        _ server: SavedMinecraftServer,
        isPresented: Binding<Bool>,
        parentViewRefreshCallBack: @escaping () -> Void = {}
    ) {
        self.server = server
        _isPresented = isPresented
        self.parentViewRefreshCallBack = parentViewRefreshCallBack
    }
    
    @FocusState private var focusedField: FocusedField?
    
    @State var tempNameInput = ""
    @State var tempServerInput = ""
    @State var tempPortInput: Int? = nil
    @State var tempServerType = ServerType.Java
    
    @State var portLabelPromptText = "Port (Optional - Default 25565)"
    
    @State private var showingInvalidURLAlert = false
    @State private var showingInvalidNameAlert = false
    @State private var showingInvalidPortAlert = false
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.gray)
                            .headline()
                            .frame(width: 25, height: 25)
                        
                        Text("Server Type")
                    }
                    
                    Picker("Server Type", selection: $tempServerType) {
                        Text("Java Edition")
                            .tag(ServerType.Java)
                        
                        Text("Bedrock/MCPE")
                            .tag(ServerType.Bedrock)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: tempServerType, initial: false) { _, newValue in
                        if newValue == .Java {
                            portLabelPromptText = "Port (Optional - Default 25565)"
                        } else if newValue == .Bedrock {
                            portLabelPromptText = "Port (Optional - Default 19132)"
                        }
                    }
                }
                
                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundColor(.gray)
                        .headline()
                        .frame(width: 25, height: 25)
                    
                    TextField("Server Name", text: $tempNameInput, prompt: Text("Server Name"))
                        .textInputAutocapitalization(.words)
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
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                        .autocorrectionDisabled(true)
                        .submitLabel(.done)
                        .focused($focusedField, equals: .serverAddress)
                        .onChange(of: tempServerInput, initial: false) { _, newValue  in
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
                        .keyboardType(.numberPad)
                }
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
                    isPresented = false
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
            
            if server.serverPort != 0 {
                tempPortInput = server.serverPort
            }
            
            tempNameInput = server.name
            tempServerType = server.serverType
            focusedField = .serverName
        }
        .interactiveDismissDisabled(inputHasChanged())
        .alert("Invalid Server URL/IP Address", isPresented: $showingInvalidURLAlert) {
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
    
    private func extractPort(_ text: String) {
        // Check if text contains a colomn
        if let colonIndex = text.firstIndex(of: ":") {
            // Extract the port number after the colon
            let portValue = text[text.index(after: colonIndex)...]
            let port = String(portValue)
            
            // Remove the port from serverIP if necessary
            let serverIP = String(text[..<colonIndex])
            tempServerInput = serverIP
            tempPortInput = Int(port)
        }
    }
    
    private func saveDisabled() -> Bool {
        tempNameInput.isEmpty || tempServerInput.isEmpty
    }
    
    private func inputHasChanged() -> Bool {
        tempNameInput != server.name ||
        tempServerInput != server.serverUrl ||
        (tempPortInput ?? 0) != server.serverPort
    }
    
    // server domains cannot have / or :
    private func isUrlValid(url: String) -> Bool {
        !url.contains(":") && !url.contains("/")
    }
    
    // CALLED WHEN A SERVER IS EDITED OR ADDED
    private func saveItem() {
        // first validate url doesnt contains any / or :
        tempServerInput = tempServerInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !isUrlValid(url: tempServerInput) {
            showingInvalidURLAlert = true
            return
        }
        
        tempNameInput = tempNameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if tempNameInput.isEmpty {
            showingInvalidNameAlert = true
            return
        }
        
        if let tempPortInput,tempPortInput < 0 || tempPortInput > 65535 {
            showingInvalidPortAlert = true
            return
        }
        
        withAnimation {
            server.serverUrl = tempServerInput
            
            if let tempPortInput {
                server.serverPort = tempPortInput
                
            } else if tempServerType == .Java {
                server.serverPort = 25565
                
            } else if tempServerType == .Bedrock {
                server.serverPort = 19132
            }
            
            server.name = tempNameInput
            server.serverType = tempServerType
            server.srvServerUrl = ""
            server.srvServerPort = 0
            modelContext.insert(server)
            
            do {
                try modelContext.save()
            } catch {
                print(error.localizedDescription)
            }
            
            print("added server")
            
            ShortcutsProvider.updateAppShortcutParameters()
            
            parentViewRefreshCallBack()
            refreshAllWidgets()
            
            isPresented = false
        }
    }
}

//#Preview {
//    EditServerView(server: )
//}

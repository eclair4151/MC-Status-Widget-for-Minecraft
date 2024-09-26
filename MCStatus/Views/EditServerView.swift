//
//  EditServerView.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/13/23.
//

import SwiftUI
import SwiftData
import MCStatusDataLayer
//import MCStatusAppIntentsExtension

struct EditServerView: View {
    
    private enum FocusedField {
        case serverName, serverAddress
    }
    
    @Environment(\.modelContext) private var modelContext

    @State var server: SavedMinecraftServer
    @Binding var isPresented: Bool
    var parentViewRefreshCallBack: () -> Void
    
    @FocusState private var focusedField: FocusedField?

    @State var tempNameInput = ""
    @State var tempServerInput = ""
    @State var tempPortInput: Int? = nil
    @State var tempServerType = ServerType.Java

    @State var portLabelPromptText = "Port (Optional - Default 25565)"

    
    var body: some View {
        Form {
            Section(header: Text("Start monitoring a server"), footer: Text("*MCStatus is used for checking the status an existing server. It will not create, setup, or host a new server.").padding(EdgeInsets(top: 10,leading: 0,bottom: 0,trailing: 0))) {
                HStack { Image(systemName: "list.bullet")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .frame(width: 25, height: 25)
                    Picker("Server Type"
                           , selection: $tempServerType) {
                        Text("Java Edition").tag(ServerType.Java)
                        Text("Bedrock/MCPE").tag(ServerType.Bedrock)
                    }.onChange(of: tempServerType, initial: false) { oldValue, newValue in
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
                        .font(.headline)
                        .frame(width: 25, height: 25)
                    TextField("Server Name", text: $tempNameInput, prompt: Text("Server Name")).textInputAutocapitalization(.words).submitLabel(.next).focused($focusedField, equals: .serverName).onSubmit {
                        focusedField = .serverAddress
                    }
                }
                HStack {
                    Image(systemName: "rectangle.connected.to.line.below")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .frame(width: 25, height: 25)
                    TextField("Server Address/IP", text: $tempServerInput, prompt: Text("Server Address/IP")).autocapitalization(.none).keyboardType(.URL).autocorrectionDisabled(true).submitLabel(.done).focused($focusedField, equals: .serverAddress)
                }
                HStack {
                    Image(systemName: "number")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .frame(width: 25, height: 25)
                    TextField(portLabelPromptText, value: $tempPortInput, formatter: NumberFormatter(), prompt: Text(portLabelPromptText)).keyboardType(.numberPad)
                }
            }.headerProminence(.increased)
        }
            .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    isPresented = false
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    addItem()
                } label: {
                    Text("Save")
                }.disabled(saveDisabled())
            }
            
        }
            .onAppear {
            tempServerInput = server.serverUrl
            if (server.serverPort != 0) {
                tempPortInput = server.serverPort
            }
            tempNameInput = server.name
            tempServerType = server.serverType
        }.interactiveDismissDisabled(inputHasChanged())
    }
    
    private func saveDisabled() -> Bool {
        return tempNameInput.isEmpty || tempServerInput.isEmpty
    }
    
    private func inputHasChanged() -> Bool {
        tempNameInput != server.name ||
        tempServerInput != server.serverUrl ||
        (tempPortInput ?? 0) != server.serverPort
    }
    
    private func addItem() {
        withAnimation {
            server.serverUrl = tempServerInput
            if let tempPortInput {
                server.serverPort =  tempPortInput
            } else if tempServerType == .Java {
                server.serverPort = 25565
            } else if tempServerType == .Bedrock {
                server.serverPort = 19132
            }
            
            server.name = tempNameInput
            server.serverType = tempServerType
            modelContext.insert(server)
            do {
                // Try to save
                try modelContext.save()
            } catch {
                // We couldn't save :(
                print(error.localizedDescription)
            }
            print("added server")
//            MCStatusShortcutsProvider.updateAppShortcutParameters()
            parentViewRefreshCallBack()
            isPresented = false
        }
    }

}



//#Preview {
//    EditServerView(server: )
//}

//
//  EditServerView.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/13/23.
//

import SwiftUI
import SwiftData
import MCStatusDataLayer
//import MCStatusIntentsFramework

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
    @State var tempPortInput = 25565
    
    var body: some View {
        Form {
            Section(header: Text("Start monitoring a server"), footer: Text("*MCStatus is used for checking the status an existing server. It will not create, setup, or host a new server.").padding(EdgeInsets(top: 10,leading: 0,bottom: 0,trailing: 0))) {
                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundColor(.gray)
                        .font(.headline)
                    TextField("Server Name", text: $tempNameInput, prompt: Text("Server Name")).textInputAutocapitalization(.words).submitLabel(.next).focused($focusedField, equals: .serverName).onSubmit {
                        focusedField = .serverAddress
                    }
                }
                HStack {
                    Image(systemName: "rectangle.connected.to.line.below")
                        .foregroundColor(.gray)
                        .font(.headline)
                    TextField("Server Address/IP", text: $tempServerInput, prompt: Text("Server Address/IP")).autocapitalization(.none).keyboardType(.URL).autocorrectionDisabled(true).submitLabel(.done).focused($focusedField, equals: .serverAddress)
                }
                HStack {
                    Image(systemName: "number")
                        .foregroundColor(.gray)
                        .font(.headline)
                    TextField("Server Port", value: $tempPortInput, formatter: NumberFormatter(), prompt: Text("Server Port")).keyboardType(.numberPad)
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
            tempPortInput = server.serverPort
            tempNameInput = server.name
        }.interactiveDismissDisabled(inputHasChanged())
    }
    
    private func saveDisabled() -> Bool {
        return tempNameInput.isEmpty || tempServerInput.isEmpty
    }
    
    private func inputHasChanged() -> Bool {
        tempNameInput != server.name ||
        tempServerInput != server.serverUrl ||
        tempPortInput != server.serverPort
    }
    
    private func addItem() {
        withAnimation {
            server.serverUrl = tempServerInput
            server.serverPort = tempPortInput
            server.name = tempNameInput
//            server.serverType = .Bedrock
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

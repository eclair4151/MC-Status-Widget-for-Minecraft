//
//  EditServerView.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/13/23.
//

import SwiftUI
import SwiftData

struct EditServerView: View {
    
    private enum FocusedField {
        case serverName, serverAddress
    }
    
    @Environment(\.modelContext) private var modelContext

    @State var server: SavedMinecraftServer
    @Binding var isPresented: Bool
    var parentViewRefreshCallBack: () -> Void
    
    @FocusState private var focusedField: FocusedField?

    @State var tempNameInput: String = ""
    @State var tempServerInput: String = ""
    @State var tempPortInput: Int = 25565

    
    var body: some View {
        Form {
            Section(header: Text("Start tracking a new server")) {
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
            }
        }.toolbar {
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
            
        }.onAppear {
            tempServerInput = server.serverUrl!
            tempPortInput = server.serverPort!
            tempNameInput = server.name!
        }
    }
    
    private func saveDisabled() -> Bool {
        return tempNameInput.isEmpty || tempServerInput.isEmpty
    }
    
    private func addItem() {
        withAnimation {
            server.serverUrl = tempServerInput
            server.serverPort = tempPortInput
            server.name = tempNameInput
            modelContext.insert(server)
            do {
                // Try to save
                try modelContext.save()
            } catch {
                // We couldn't save :(
                print(error.localizedDescription)
            }
            print("added server")
            parentViewRefreshCallBack()
            isPresented = false
        }
    }

}



//#Preview {
//    EditServerView(server: )
//}

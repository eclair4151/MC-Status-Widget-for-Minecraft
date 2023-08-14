//
//  EditServerView.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/13/23.
//

import SwiftUI
import SwiftData

struct EditServerView: View {
    @Environment(\.modelContext) private var modelContext

    @State var server: SavedMinecraftServer
    @Binding var isPresented: Bool
    var parentViewRefreshCallBack: () -> Void

    //JUST TEMP WHILE DEFAULTS BLOCKED 
    @State var tempNameInput: String = ""
    @State var tempServerInput: String = ""
    @State var tempPortInput: Int = 25565
//    init() {
//        // initialized without a server. create a new one to bind to.
//        server = SavedMinecraftServer(id: UUID(), serverType: .Java, name: "", serverUrl: "", serverPort: 25565)
//    }
    
//    var body: some View {
//        Text("Edit Server")
//        TextField("Server Name", text: $tempNameInput)
//        TextField("Server Address/IP", text: $tempServerInput)
//        TextField("Port", value: $tempPortInput, formatter: NumberFormatter())
//        Button(action: {
//            addItem()
//        }, label: {
//            Text("Save Server")
//        }).onAppear {
//            tempServerInput = server.serverUrl!
//            tempPortInput = server.serverPort!
//            tempNameInput = server.name!
//        }
//    }
    
  
    var body: some View {
//        Form {
//                Section(header: Text("Profile")) {
//                    Text("Name").font(.headline)
//                    TextField(.constant(""), text: "", placeholder: Text("Enter your name"))
//                        .padding(.all)
//                        .background(Color(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, opacity: 0.7), cornerRadius: 8.0)
//                    }
//                    Toggle(isOn: true) {
//                        Text("Hide account")
//                    }
//                }
//                .padding(.horizontal, 16)

        Form {
            Section() {
                Text("Name").font(.headline)
            }.padding(.horizontal, 16)
            
            Section() {
                Button {
                    
                } label: {
                    Text("Save")
                }
            }
        }.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresented = false
                } label: {
                    Text("Cancel")
                }
            }
            
        }
//                Section(header: Text("Emails")) {
//                    Toggle(isOn: false) {
//                        Text("Receive emails")
//                    }
//                    TextField(.constant(""), text: "$email", placeholder: Text("Enter your email"))
//                        .padding(.all)
//                        .background(Color(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, opacity: 0.7), cornerRadius: 8.0)
//                    }
//                    Picker(selection: 1, label: Text("Email types")) {
//                        ForEach(0 ..< 3) {
//                            Text("Option: " + String($0))
//                        }
//                    }
//                }
//                
//
//                Section(header: Text("Emails")) {
//                    Slider(value: $volumeSliderValue, in: 0...100, step: 1)
//                    .padding()
//                    .accentColor(Color.blue)
//                    .border(Color.blue, width: 3)
//                }
//                .padding(.horizontal, 16)
//
//                Section(header: Text("Volume")) {
//                    Stepper("Volume is: ", value: $stepper, in: 1..10, step: 1)
//                    .padding()
//                    .accentColor(Color.blue)
//                }
//                .padding(.horizontal, 16)
//            }
    }
    
    
    private func addItem() {
        withAnimation {
//            let newItem = SavedMinecraftServer(id:UUID(), serverType: .Java, name: "tomer's Server", serverUrl: "192.168.4.72", serverPort: 25565)
//            newItem.displayOrder = serverViewModels.count + 1
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

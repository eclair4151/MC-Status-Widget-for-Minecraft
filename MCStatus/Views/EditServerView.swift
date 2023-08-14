//
//  EditServerView.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/13/23.
//

import SwiftUI

struct EditServerView: View {
    @State var server: SavedMinecraftServer
    @Binding var isPresented: Bool

    //JUST TEMP WHILE DEFAULTS BLOCKED 
    @State var tempServerInput: String = ""
//    init() {
//        // initialized without a server. create a new one to bind to.
//        server = SavedMinecraftServer(id: UUID(), serverType: .Java, name: "", serverUrl: "", serverPort: 25565)
//    }
    
    var body: some View {
        Text("Edit Server")
        TextField("Server Address/IP", text: $tempServerInput)
        Button(action: {
            isPresented = false
        }, label: {
            Text("Save Server")
        })
    }
}

//#Preview {
//    EditServerView(server: )
//}

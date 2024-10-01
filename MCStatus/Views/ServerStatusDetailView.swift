//
//  ServerDetailView.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/9/23.
//

import SwiftUI
import MCStatusDataLayer
import AppIntents




struct ServerStatusDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State var serverStatusViewModel: ServerStatusViewModel

    var parentViewRefreshCallBack: () -> Void
    
    private var pillText: String {
            var text = "Loading"
            if let status = serverStatusViewModel.status, serverStatusViewModel.loadingStatus != .Loading {
                text = status.status.rawValue
            }
            return text
        }
    
    private var pillColor: Color {
            var color = Color.gray
            if let status = serverStatusViewModel.status, serverStatusViewModel.loadingStatus != .Loading {
                if status.status == .Online {
                    color = Color.green
                } else if status.status == .Offline {
                    color = Color.red
                }
            }
            return color
        }
    
    private var playersText: String {
        var text = ""
        if let status = serverStatusViewModel.status {
            text = "Players: \(status.onlinePlayerCount)/\(status.maxPlayerCount)"
        }
        return text
    }
    
    private var srvAddressText: String {
        var text = ""
        if(serverStatusViewModel.hasSRVRecord()) {
            text = "SRV: " + serverStatusViewModel.server.srvServerUrl + ":" + String(serverStatusViewModel.server.srvServerPort)
        }
        return text
    }
    
    
    
//    private var serverTypeText: String {
//        switch(serverStatusViewModel.server.serverType) {
//        case .Java:
//            return "Java"
//        case .Bedrock:
//            return "Bedrock"
//        }
//    }
    
    
    

//    var serverName: String = "Zero's Server"
//    var serverType: String = "Java"
//    var serverVersion: String = "Paper 1.21"
//    var serverAddress: String = "myserver.com:25565"
//    var srvRecordValue: String = "srv: otherserver.com:25565"
//    var pingValue: String = "Ping: 100ms"
//    var isOnline: Bool = true
//    var currentPlayers: Int = 12
//    var maxPlayers: Int = 20
//    var onlinePlayers: [Player] = [Player(name: "Player1", id: "c5ef3347-4593-4f39-8bb1-2eaa40dd986e")]

    
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top, spacing: 0) {
                            
                            Image("DefaultIcon")
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(15)
                                .background(Color.serverIconBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay(RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color(hex: "6e6e6e"), lineWidth: 2))
                                .frame(width: proxy.size.width * 0.3)
                                .padding([.trailing], 16)
                                .shadow(color: .black.opacity(0.25), radius: 10, x: 5, y: 5) // Drop shadow
     
                            
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(serverStatusViewModel.server.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                let serverAddressString = serverStatusViewModel.server.serverUrl + ":" + String(serverStatusViewModel.server.serverPort)
                                Text(serverAddressString)
                                    .font(.subheadline)
                                    .foregroundColor(.secondaryTextColor)
                                    .lineLimit(1)
                                
                                Text(srvAddressText)
                                    .font(.subheadline)
                                    .foregroundColor(.secondaryTextColor)
                                    .lineLimit(1)
                                
                                // Status pill
                                HStack {
                                    Text(pillText)
                                        .padding([.trailing, .leading], 18)
                                        .padding([.bottom, .top], 8)
                                        .background(pillColor)
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                    
                                    if (serverStatusViewModel.loadingStatus == .Loading) {
                                        ProgressView()
                                    }
                                }.padding(.top, 10)
                                    
                             
                            }
                            
                        }
                        HStack {
                            Text(serverStatusViewModel.server.serverType.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.tertiaryTextColor)
                                .bold()
                            
                            if let version = serverStatusViewModel.status?.version, !version.isEmpty {
                                Text("-")
                                Text(version)
                                    .font(.subheadline)
                                    .foregroundColor(.secondaryTextColor)
                            }
                            
                        }
                        Text("Ping: 100ms")
                            .font(.subheadline)
                            .foregroundColor(.secondaryTextColor)
                        if let status = serverStatusViewModel.status, let motdText = status.description?.getRawText() {
                            Text(motdText)
                                .font(.custom("Avenir", size: 20)) // Use a Minecraft-like font
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading) // Make the Text view full width
                                .foregroundColor(.white) // Set text color to white for contrast
                                .background(Color.MOTDBackground) // Darker background
                                .cornerRadius(15) // Rounded corners
                                .padding([.top,.bottom],10) // Additional padding around the view
                                .shadow(color: Color.black.opacity(0.5), radius: 5) // Optional shadow for depth
                        }
                        
                        
                        Text(playersText)
                            .font(.headline)
                            .padding([.top, .bottom], 4)

                        CustomProgressView(progress: serverStatusViewModel.getPlayerCountPercentage())
                            .frame(height:8)
      
                        
                    }.padding([.leading], 20)
                        .padding([.top], 16)
                        .padding(.trailing, 20)
                    
                    
                    // List of online players
                    List {
                        ForEach(serverStatusViewModel.status?.playerSample ?? []) { player in
                            HStack(spacing: 0) {
                                AsyncImage(url: URL(string: "https://mc-heads.net/avatar/" + player.id)){ result in
                                           result.image?
                                               .resizable()
                                               .scaledToFill()
                                       }
                                       .cornerRadius(3)
                                       .background(.gray)
                                       .frame(width: 40, height: 40)
                                       .padding([.trailing], 16)
                                   Text(player.name)
           
                           }.listRowInsets(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                        }
                    }.listStyle(.insetGrouped).padding(.top, -10).zIndex(-1)
                }

            }.background(Color.appBackgroundColor)
        }.refreshable {
            serverStatusViewModel.reloadData()
        }.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Text("Edit")
                    }
                    Button {
                        showingDeleteAlert = true
                    } label: {
                        Label("Add Item", systemImage: "trash")
                    }
                }
            }
        }.alert("Delete Server?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteServer()
            }
            Button("Cancel", role: .cancel) { }
        }.sheet(isPresented: $showingEditSheet) {
            NavigationView {
                EditServerView(server: serverStatusViewModel.server, isPresented: $showingEditSheet) {
                    serverStatusViewModel.reloadData()
                    parentViewRefreshCallBack()
                }
            }
        }
    }
    
    private func deleteServer() {
        modelContext.delete(serverStatusViewModel.server)
        do {
            // Try to save
            try modelContext.save()
        } catch {
            // We couldn't save :(
            // Failures include issues such as an invalid unique constraint
            print(error.localizedDescription)
        }
        parentViewRefreshCallBack()
        self.presentationMode.wrappedValue.dismiss()
    }
}


//
//  ServerDetailView.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/9/23.
//

import SwiftUI
import MCStatusDataLayer
import AppIntents
import NukeUI


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
            text = "srv: " + serverStatusViewModel.server.srvServerUrl + ":" + String(serverStatusViewModel.server.srvServerPort)
        }
        return text
    }
    
    @State
    private var pingText = " "
    

    var body: some View {
        GeometryReader { proxy in
            List {
                Section(header: Spacer(minLength: 0)) {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top, spacing: 0) {
                            
                            Image(uiImage: serverStatusViewModel.serverIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: proxy.size.width * 0.3, height: proxy.size.width * 0.3)
                                .cornerRadius(15)
                                .background(Color.serverIconBackground)
                                .overlay(RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color(hex: "6e6e6e"), lineWidth: 4))
                                .clipShape(RoundedRectangle(cornerRadius: 15))

                                .padding([.trailing], 16)
                                .shadow(color: .black.opacity(0.25), radius: 10, x: 3, y: 3) // Drop shadow
                            
                            
                            
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
                        HStack(alignment: .top) {
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
                        Text(pingText)
                            .font(.subheadline)
                            .foregroundColor(.secondaryTextColor)
                        if let status = serverStatusViewModel.status, let motdText = status.description?.getRawText() {
                            Text(motdText)
                                .font(.custom("Avenir", size: 15)) // Use a Minecraft-like font
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading) // Make the Text view full width
                                .foregroundColor(.white) // Set text color to white for contrast
                                .background(Color.MOTDBackground) // Darker background
                                .cornerRadius(15) // Rounded corners
                                .padding(.top,5) // Additional padding around the view
                                .padding(.bottom, 15)
                        }
                        
                        
                        Text(playersText)
                            .font(.headline)
                        
                        CustomProgressView(progress: serverStatusViewModel.getPlayerCountPercentage())
                            .frame(height:10).padding(.bottom, 10)
                        
                        
                    }
                }.listRowInsets(EdgeInsets())
                    .listRowBackground(Color.appBackgroundColor)
                
                Section {
                    ForEach(serverStatusViewModel.status?.playerSample ?? []) { player in
                        HStack(spacing: 0) {
                            let imageUrl = URL(string: "https://mc-heads.net/avatar/" + player.uuid)
//                            let imageUrl = URL(string: "https://httpbin.org/delay/10")
                            LazyImage(url: imageUrl) { state in
                                if let image = state.image {
                                    image.resizable().scaledToFill()
                                } else if state.error != nil {
                                    Color.placeholderGrey
                                } else {
                                    ZStack {
                                        Color.placeholderGrey
                                        ProgressView().opacity(0.3)
                                    }
                                }
                            }
                            .cornerRadius(3)
                                .frame(width: 40, height: 40)
                                .padding([.trailing], 16)
                                Text(player.name)
                            
                       }.listRowInsets(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                    }
                } footer: {
                    let playerSampleCount = serverStatusViewModel.status?.playerSample.count ?? 0
                    let onlinePlayersCount = serverStatusViewModel.status?.onlinePlayerCount ?? 0
                    
                    if (playerSampleCount > 0 && playerSampleCount < onlinePlayersCount) {
                        Text("*Player list limited to 12 users by server").frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }.listStyle(.insetGrouped).listSectionSpacing(10).environment(\.defaultMinListHeaderHeight, 5)
        }.refreshable {
            serverStatusViewModel.reloadData()
            refreshPing()
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
        }.onAppear {
            refreshPing()
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
    
    private func refreshPing() {
        Task {
            let pingResult = await SwiftyPing.pingServer(serverUrl: serverStatusViewModel.getServerAddressToPing())
            guard pingResult.error == nil else {
                return
            }
            let pingDuration = Int(round(pingResult.duration * 1000))
            self.pingText = "Ping: " + String(pingDuration) + "ms"
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


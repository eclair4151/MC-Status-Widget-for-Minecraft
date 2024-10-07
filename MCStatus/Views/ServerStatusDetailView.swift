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
import Nuke

struct ServerStatusDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State var serverStatusViewModel: ServerStatusViewModel

    var parentViewRefreshCallBack: () -> Void
    
    var prefetcher = ImagePrefetcher()

    private var pillText: String {
            var text = " "
            if let status = serverStatusViewModel.status, serverStatusViewModel.loadingStatus != .Loading {
                text = status.status.rawValue
            }
            return text
        }
    
    private var pillColor: Color {
            var color = Color.standoutPillGrey
            if let status = serverStatusViewModel.status, serverStatusViewModel.loadingStatus != .Loading {
                if status.status == .Online {
                    color = Color.statusBackgroundGreen
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
    
    private func pingColor(for strength: Int) -> Color {
            switch strength {
            case 1 ... 75:
                return Color.statusBackgroundGreen
            case 76 ... 200:
                return Color.statusBackgroundYellow
            case 200 ... Int.max:
                return .red
            default:
                return .gray
            }
        }
    
    
    @State
    private var pingDuration = 0
    
    
    var body: some View {
            List {
                Section(header: Spacer(minLength: 0)) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top, spacing: 0) {
                            Image(uiImage: serverStatusViewModel.serverIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .cornerRadius(15)
                                .background(Color.serverIconBackground)
                                .overlay(RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color(hex: "6e6e6e"), lineWidth: 4))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .padding([.trailing], 16)
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 3, y: 3) // Drop shadow
                            
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(serverStatusViewModel.server.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                let serverAddressString = serverStatusViewModel.server.serverUrl + ":" + String(serverStatusViewModel.server.serverPort)
                                Text(serverAddressString)
                                    .font(.footnote)
                                    .foregroundColor(.secondaryTextColor)
                                    .lineLimit(1)
                                
                                if !srvAddressText.isEmpty {
                                    Text(srvAddressText)
                                        .font(.footnote)
                                        .foregroundColor(.secondaryTextColor)
                                        .lineLimit(1)
                                }
                                
                                // Status pill
                                HStack(alignment: .center) {
                                    ZStack(alignment: .center) {
                                        Text(pillText)
                                            .frame(minWidth: 45)
                                            .padding([.trailing, .leading], 14)
                                            .padding([.bottom, .top], 7)
                                            .background(pillColor)
                                            .foregroundColor(.white)
                                            .font(.subheadline)
                                            .cornerRadius(16)
                                            
                                        
                                        if (serverStatusViewModel.loadingStatus == .Loading) {
                                            ProgressView()
                                        }
                                    }
                                    
                                    if self.pingDuration > 0 {
                                        HStack {
                                            
                                            Text("\(self.pingDuration)ms")
                                                .font(.subheadline)
                                            Image(systemName: "wifi")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundColor(pingColor(for: self.pingDuration))
                                                        .frame(width: 15, height: 15)
                                        }.padding([.trailing, .leading], 14)
                                            .padding([.bottom, .top], 7)
                                            .background(Color.standoutPillGrey)
                                            .foregroundColor(.tertiaryTextColor)
                                            .cornerRadius(16)
                                            
                                    }
                                    
                                }.padding(.top, 8)
                            }
                        }.padding(.bottom, 8)
                        
                        HStack(alignment: .top) {
                            Text(serverStatusViewModel.server.serverType.rawValue)
                                .font(.subheadline)
                                .padding([.trailing, .leading], 6)
                                .padding([.bottom, .top], 3)
                                .background(Color.standoutPillGrey)
                                .cornerRadius(6)
                                .foregroundColor(.tertiaryTextColor)
                                .bold()
                            if let version = serverStatusViewModel.status?.version, !version.isEmpty {
                                Text(version)
                                    .font(.subheadline)
                                    .padding(.top, 3)
                                    .foregroundColor(.secondaryTextColor)
                            }
                        }
                        
                        if let status = serverStatusViewModel.status, let motdText = status.description?.getRawText() {
                            Text(motdText)
                                .font(Font.minecraftFont) // Use a Minecraft-like font
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading) // Make the Text view full width
                                .foregroundColor(.white) // Set text color to white for contrast
                                .background(Color.MOTDBackground) // Darker background
                                .cornerRadius(15) // Rounded corners
                                .padding(.top,10) // Additional padding around the view
                                .padding(.bottom, 15)
                        }
                        
                        Text(playersText)
                            .font(.headline)
                            .padding(.bottom, 10)
                        CustomProgressView(progress: serverStatusViewModel.getPlayerCountPercentage())
                            .frame(height:10).padding(.bottom, 10)
                        
                        
                    }
                }.padding([.top, .trailing, .leading],10).listRowInsets(EdgeInsets())
                    .listRowBackground(Color.appBackgroundColor)
                
                Section {
                    ForEach(serverStatusViewModel.status?.playerSample ?? []) { player in
                        HStack(spacing: 0) {
                            let imageUrl = URL(string: getMcHeadsUrl(uuid: player.uuid))
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
                                .frame(width: 30, height: 30)
                                .padding([.trailing], 16)
                                Text(player.name)
                            
                        }.padding(.vertical, 10).listRowInsets(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                    }
                } footer: {
                    let playerSampleCount = serverStatusViewModel.status?.playerSample.count ?? 0
                    let onlinePlayersCount = serverStatusViewModel.status?.onlinePlayerCount ?? 0
                    
                    if (playerSampleCount > 0 && playerSampleCount < onlinePlayersCount) {
                        Text("*Player list limited to 12 users by server").frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }.listStyle(.insetGrouped).listSectionSpacing(10).environment(\.defaultMinListHeaderHeight, 15)
            .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            serverStatusViewModel.reloadData(config: UserDefaultHelper.getServerCheckerConfig())
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
            startPrefetchingUserImages(viewModel: serverStatusViewModel)
        }.alert("Delete Server?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteServer()
            }
            Button("Cancel", role: .cancel) { }
        }.sheet(isPresented: $showingEditSheet) {
            NavigationView {
                EditServerView(server: serverStatusViewModel.server, isPresented: $showingEditSheet) {
                    serverStatusViewModel.reloadData(config: UserDefaultHelper.getServerCheckerConfig())
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
            self.pingDuration = pingDuration
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
    
    func startPrefetchingUserImages(viewModel: ServerStatusViewModel) {
        let imageURLs = (viewModel.status?.playerSample ?? []).compactMap {
            URL(string: getMcHeadsUrl(uuid: $0.uuid))
        }

        // Initialize and start prefetching all the image URLs
        prefetcher.startPrefetching(with: imageURLs)
    }
    
    func getMcHeadsUrl(uuid: String) -> String{
        return "https://mc-heads.net/avatar/" + uuid + "/90"
    }
}


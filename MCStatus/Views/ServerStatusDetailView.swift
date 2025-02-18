import SwiftUI
import MCStatusDataLayer
import NukeUI
import Nuke
import WidgetKit

struct ServerStatusDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State var serverStatusVM: ServerStatusVM
    
    var parentViewRefreshCallBack: () -> Void
    
    var prefetcher = ImagePrefetcher()
    
    // Ping updater
    private let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    
    private var pillText: String {
        if let status = serverStatusVM.status, serverStatusVM.loadingStatus != .Loading {
            status.status.rawValue
        } else {
            " "
        }
    }
    
    private var pillColor: Color {
        var color = Color.standoutPillGrey
        
        if let status = serverStatusVM.status, serverStatusVM.loadingStatus != .Loading {
            if status.status == .Online {
                color = Color.statusBackgroundGreen
            } else if status.status == .Offline {
                color = Color.red
            }
        }
        
        return color
    }
    
    private var playersText: String {
        if let status = serverStatusVM.status {
            "Players: \(status.onlinePlayerCount)/\(status.maxPlayerCount)"
        } else {
            ""
        }
    }
    
    private var srvAddressText: String {
        if serverStatusVM.hasSRVRecord() {
            "srv: " + serverStatusVM.server.srvServerUrl + ":" + String(serverStatusVM.server.srvServerPort)
        } else {
            ""
        }
    }
    
    private func pingColor(for strength: Int) -> Color {
        switch strength {
        case 1...75:        .statusBackgroundGreen
        case 76...200:      .statusBackgroundYellow
        case 200...Int.max: .red
        default:            .gray
        }
    }
    
    @State private var pingDuration = 0
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        Image(uiImage: serverStatusVM.serverIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .cornerRadius(15)
                            .background(Color.serverIconBackground)
                            .overlay {
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color(hex: "6e6e6e"), lineWidth: 4)
                            }
                            .clipShape(.rect(cornerRadius: 15))
                            .padding(.trailing, 16)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 3, y: 3) // Drop shadow
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(serverStatusVM.server.name)
                                .title(.bold)
                            
                            let serverAddressString = serverStatusVM.server.serverUrl + ":" + String(serverStatusVM.server.serverPort)
                            
                            Text(serverAddressString)
                                .footnote()
                                .foregroundColor(.secondaryTextColor)
                                .lineLimit(1)
                            
                            if !srvAddressText.isEmpty {
                                Text(srvAddressText)
                                    .footnote()
                                    .foregroundColor(.secondaryTextColor)
                                    .lineLimit(1)
                            }
                            
                            // Status pill
                            HStack(alignment: .center) {
                                ZStack(alignment: .center) {
                                    Text(pillText)
                                        .frame(minWidth: 45)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(pillColor)
                                        .foregroundColor(.white)
                                        .subheadline()
                                        .cornerRadius(16)
                                    
                                    if serverStatusVM.loadingStatus == .Loading {
                                        ProgressView()
                                    }
                                }
                                
                                if pingDuration > 0 {
                                    HStack {
                                        Text("\(pingDuration)ms")
                                            .monospacedDigit()
                                            .subheadline()
                                        
                                        Image(systemName: "wifi")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(pingColor(for: pingDuration))
                                            .frame(width: 15, height: 15)
                                        // .symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing, options: .repeat(.continuous))
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(Color.standoutPillGrey)
                                    .foregroundColor(.tertiaryTextColor)
                                    .cornerRadius(16)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    HStack(alignment: .top) {
                        Text(serverStatusVM.server.serverType.rawValue)
                            .subheadline(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.standoutPillGrey)
                            .cornerRadius(6)
                            .foregroundColor(.tertiaryTextColor)
                        
                        if let version = serverStatusVM.status?.version, !version.isEmpty {
                            Text(version)
                                .subheadline()
                                .padding(.top, 3)
                                .foregroundColor(.secondaryTextColor)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    if let status = serverStatusVM.status, let _ = status.description {
                        status.generateMOTDView()
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading) // Make the Text view full width
                            .background(Color.MOTDBackground) // Darker background
                            .cornerRadius(15)
                    }
                    
                    Text(playersText)
                        .headline()
                        .padding(.bottom, 10)
                        .padding(.top, 15)
                    
                    CustomProgressView(progress: serverStatusVM.getPlayerCountPercentage())
                        .frame(height:10)
                        .padding(.bottom, 10)
                }
            } header: {
                Spacer(minLength: 0)
            }
            .padding([.top, .trailing, .leading], 10)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.appBackgroundColor)
            
            Section {
                ForEach(serverStatusVM.status?.playerSample ?? []) { player in
                    HStack(spacing: 0) {
                        let imageUrl = URL(string: serverStatusVM.getMcHeadsUrl(uuid: player.uuid))
                        //                            let imageUrl = URL(string: "https://httpbin.org/delay/10")
                        
                        LazyImage(url: imageUrl) { state in
                            if let image = state.image {
                                image.resizable().scaledToFit()
                                
                            } else if state.error != nil {
                                Color.placeholderGrey
                                
                            } else {
                                ZStack {
                                    Color.placeholderGrey
                                    
                                    ProgressView()
                                        .opacity(0.3)
                                }
                            }
                        }
                        .cornerRadius(3)
                        .frame(width: 30, height: 30)
                        .padding(.trailing, 16)
                        
                        Text(player.name)
                    }
                    .padding(.vertical, 10)
                    .listRowInsets(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                }
            } footer: {
                let playerSampleCount = serverStatusVM.status?.playerSample.count ?? 0
                let onlinePlayersCount = serverStatusVM.status?.onlinePlayerCount ?? 0
                
                if playerSampleCount > 0 && playerSampleCount < onlinePlayersCount {
                    Text("*Player list limited to \(playerSampleCount) users by server")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(10)
        .environment(\.defaultMinListHeaderHeight, 15)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            if !lowPowerMode {
                refreshPing()
            }
        }
        .refreshable {
            serverStatusVM.reloadData(ConfigHelper.getServerCheckerConfig())
            refreshPing()
        }
        .toolbar {
#if targetEnvironment(macCatalyst) // Gross (show refresh button only on mac status bar since they can't pull to refresh)
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    serverStatusVM.reloadData(ConfigHelper.getServerCheckerConfig())
                    refreshPing()
                } label: {
                    Label("Refresh Servers", systemImage: "arrow.clockwise")
                }
            }
#endif
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Server", systemImage: "trash")
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .onAppear {
            refreshPing()
            startPrefetchingUserImages(vm: serverStatusVM)
        }
        .alert("Delete Server?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteServer()
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .sheet($showingEditSheet) {
            NavigationStack {
                EditServerView(serverStatusVM.server, isPresented: $showingEditSheet) {
                    serverStatusVM.reloadData(ConfigHelper.getServerCheckerConfig())
                    parentViewRefreshCallBack()
                }
            }
        }
    }
    
    private func refreshPing() {
        Task {
            let pingResult = await SwiftyPing.pingServer(serverUrl: serverStatusVM.getServerAddressToPing())
            
            guard pingResult.error == nil else {
                return
            }
            
            let pingDuration = Int(round(pingResult.duration * 1000))
            self.pingDuration = pingDuration
        }
    }
    
    private func deleteServer() {
        modelContext.delete(serverStatusVM.server)
        
        do {
            // Try to save
            try modelContext.save()
        } catch {
            // We couldn't save :(
            // Failures include issues such as an invalid unique constraint
            print(error.localizedDescription)
        }
        
        // Refresh widgets
        WidgetCenter.shared.reloadAllTimelines()
        
        parentViewRefreshCallBack()
        self.presentationMode.wrappedValue.dismiss()
    }
    
    private func startPrefetchingUserImages(vm: ServerStatusVM) {
        let imageURLs = (vm.status?.playerSample ?? []).compactMap {
            URL(string: vm.getMcHeadsUrl(uuid: $0.uuid))
        }
        
        // Init and start prefetching all the image URLs
        prefetcher.startPrefetching(with: imageURLs)
    }
}

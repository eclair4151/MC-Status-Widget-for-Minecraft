import SwiftUI
import MCStatusDataLayer
import Nuke

struct ServerStatusDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State var vm: ServerStatusVM
    var parentViewRefreshCallBack: () -> Void
    
    init(_ vm: ServerStatusVM, parentViewRefreshCallBack: @escaping () -> Void) {
        self.vm = vm
        self.parentViewRefreshCallBack = parentViewRefreshCallBack
    }
    
    @State private var pingDuration = 0
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    // Ping updater
    private let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    private var prefetcher = ImagePrefetcher()
    
    private var pillText: String {
        if let status = vm.status, vm.loadingStatus != .Loading {
            status.status.rawValue
        } else {
            " "
        }
    }
    
    private var pillColor: Color {
        var color = Color.standoutPillGrey
        
        if let status = vm.status, vm.loadingStatus != .Loading {
            if status.status == .Online {
                color = Color.statusBackgroundGreen
            } else if status.status == .Offline {
                color = Color.red
            }
        }
        
        return color
    }
    
    private var playersText: String {
        if let status = vm.status {
            "Players: \(status.onlinePlayerCount)/\(status.maxPlayerCount)"
        } else {
            ""
        }
    }
    
    private var srvAddressText: String {
        if vm.hasSRVRecord() {
            "srv: " + vm.server.srvServerUrl + ":" + String(vm.server.srvServerPort)
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
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        Image(uiImage: vm.serverIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .cornerRadius(15)
                            .clipShape(.rect(cornerRadius: 15))
                            .padding(.trailing, 16)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 3, y: 3) // Drop shadow
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(vm.server.name)
                                .title(.bold)
                            
                            let serverAddressString = vm.server.serverUrl + ":" + String(vm.server.serverPort)
                            
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
                                    
                                    if vm.loadingStatus == .Loading {
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
                        Text(vm.server.serverType.rawValue)
                            .subheadline(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.standoutPillGrey)
                            .cornerRadius(6)
                            .foregroundColor(.tertiaryTextColor)
                        
                        if let version = vm.status?.version, !version.isEmpty {
                            Text(version)
                                .subheadline()
                                .padding(.top, 3)
                                .foregroundColor(.secondaryTextColor)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    if let status = vm.status, let _ = status.description {
                        status.generateMOTDView()
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading) // Make the Text view full width
                            .cornerRadius(15)
                    }
                    
                    Text(playersText)
                        .headline()
                        .padding(.bottom, 10)
                        .padding(.top, 15)
                    
                    CustomProgressView(progress: vm.getPlayerCountPercentage())
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
                ForEach(vm.status?.playerSample ?? []) { player in
                    PlayerCard(player)
                }
            } footer: {
                let playerSampleCount = vm.status?.playerSample.count ?? 0
                let onlinePlayerCount = vm.status?.onlinePlayerCount ?? 0
                
                if playerSampleCount > 0 && playerSampleCount < onlinePlayerCount {
                    Text("Player list limited to \(playerSampleCount) users by server")
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(10)
        .scrollIndicators(.never)
        .environment(vm)
        .environment(\.defaultMinListHeaderHeight, 15)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            if !lowPowerMode {
                refreshPing()
            }
        }
        .refreshable {
            vm.reloadData(ConfigHelper.getServerCheckerConfig())
            refreshPing()
        }
        .toolbar {
            // Gross (show refresh button only on Mac status bar since they can't pull to refresh)
#if targetEnvironment(macCatalyst)
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
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Server", systemImage: "trash")
                    }
                    .foregroundColor(.red)
                    
                    Button("Edit") {
                        showingEditSheet = true
                    }
                }
            }
        }
        .onAppear {
            refreshPing()
            startPrefetchingUserImages(vm)
        }
        .alert("Delete Server?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteServer()
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .sheet($showingEditSheet) {
            NavigationStack {
                EditServerView(vm.server, isPresented: $showingEditSheet) {
                    vm.reloadData(ConfigHelper.getServerCheckerConfig())
                    parentViewRefreshCallBack()
                }
            }
        }
    }
    
    private func refreshPing() {
        Task {
            let pingResult = await SwiftyPing.pingServer(vm.getServerAddressToPing())
            
            guard pingResult.error == nil else {
                return
            }
            
            let pingDuration = Int(round(pingResult.duration * 1000))
            self.pingDuration = pingDuration
        }
    }
    
    private func deleteServer() {
        modelContext.delete(vm.server)
        
        do {
            try modelContext.save()
        } catch {
            // Failures include issues such as an invalid unique constraint
            print(error.localizedDescription)
        }
        
        refreshAllWidgets()
        
        parentViewRefreshCallBack()
        self.presentationMode.wrappedValue.dismiss()
    }
    
    private func startPrefetchingUserImages(_ vm: ServerStatusVM) {
        let imageURLs = (vm.status?.playerSample ?? []).compactMap {
            URL(string: vm.getMcHeadsUrl(uuid: $0.uuid))
        }
        
        // Init and start prefetching all the image URLs
        prefetcher.startPrefetching(with: imageURLs)
    }
}

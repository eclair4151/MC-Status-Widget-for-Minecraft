import SwiftUI
import MCStatsDataLayer
import Nuke

struct ServerDetails: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State var vm: ServerStatusVM
    var parentViewRefreshCallBack: () -> Void
    
    init(_ vm: ServerStatusVM, parentViewRefreshCallBack: @escaping () -> Void) {
        self.vm = vm
        self.parentViewRefreshCallBack = parentViewRefreshCallBack
    }
    
    @State private var pings: [ServerPing] = []
    @State private var pingDuration = 0
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var sheetPings = false
    
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
            "SRV: " + vm.server.srvServerUrl + ":" + String(vm.server.srvServerPort)
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
#if os(macOS)
                        Image(nsImage: vm.serverIcon)
                            .serverIconStyle()
#else
                        Image(uiImage: vm.serverIcon)
                            .serverIconStyle()
#endif
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
                                    Button {
                                        sheetPings = true
                                    } label: {
                                        HStack {
                                            Text("\(pingDuration) ms")
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
                                    .buttonStyle(.plain)
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
                    
                    MOTDView(vm.status)
                    
                    Text(playersText)
                        .headline()
                        .padding(.bottom, 10)
                        .padding(.top, 15)
                    
                    CustomProgressView(progress: vm.getPlayerCountPercentage())
                        .frame(height: 10)
                        .padding(.bottom, 10)
                }
            } header: {
                Spacer(minLength: 0)
            }
            .padding([.top, .trailing, .leading], 10)
            .listRowInsets(EdgeInsets())
            
            PlayerList()
        }
        .scrollIndicators(.never)
        .environment(vm)
#if !os(tvOS) && !os(macOS)
        .listSectionSpacing(10)
        .listStyle(.insetGrouped)
        .environment(\.defaultMinListHeaderHeight, 15)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .onReceive(timer) { _ in
            if !lowPowerMode {
                refreshPing()
            }
        }
        .refreshable {
            vm.reloadData(ConfigHelper.getServerCheckerConfig())
            refreshPing()
        }
        .sheet($sheetPings) {
            PingGraph($pings)
        }
        .toolbar {
#if os(macOS)
            let leadingPlacement: ToolbarItemPlacement = .navigation
            let trailingPlacement: ToolbarItemPlacement = .primaryAction
#else
            let leadingPlacement: ToolbarItemPlacement = .topBarLeading
            let trailingPlacement: ToolbarItemPlacement = .topBarTrailing
#endif
            
#if os(macOS)
            ToolbarItem(placement: .primaryAction) {
                Button {
                    vm.reloadData(ConfigHelper.getServerCheckerConfig())
                    refreshPing()
                } label: {
                    Label("Refresh Servers", systemImage: "arrow.clockwise")
                }
            }
#endif
            ToolbarItemGroup(placement: trailingPlacement) {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
#if os(tvOS)
                    Text("Delete")
                        .foregroundStyle(.red)
#else
                    Label("Delete Server", systemImage: "trash")
#endif
                }
                .foregroundColor(.red)
                
                Button("Edit") {
                    showingEditSheet = true
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
                print("Ping error:", pingResult.error ?? "Unknown")
                return
            }
            
            let pingDuration = Int(round(pingResult.duration * 1000))
            self.pingDuration = pingDuration
            
            pings.append(
                ServerPing(pingDuration)
            )
            
            if pings.count > 60 {
                pings.removeFirst()
            }
        }
    }
    
    private func startPrefetchingUserImages(_ vm: ServerStatusVM) {
        let imageURLs = (vm.status?.playerSample ?? []).compactMap {
            URL(string: vm.getMcHeadsUrl($0.uuid))
        }
        
        // Init and start prefetching all the image URLs
        prefetcher.startPrefetching(with: imageURLs)
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
        presentationMode.wrappedValue.dismiss()
    }
}

fileprivate extension Image {
    func serverIconStyle() -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .cornerRadius(15)
            .clipShape(.rect(cornerRadius: 15))
            .padding(.trailing, 16)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 3, y: 3) // Drop shadow
    }
}

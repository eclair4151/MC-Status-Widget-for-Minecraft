import SwiftUI
import SwiftData
import CoreData
import MCStatsDataLayer

struct AppContainer: View {
    @State var nav = NavigationPath()
    var reviewHelper = ReviewHelper()
#if os(iOS)
    private let watchHelper = WatchHelper()
#endif
    
#if !os(tvOS)
    @Environment(\.requestReview) var requestReview
#endif
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) var modelContext
    
    @State var servers: [ServerStatusVM]?
    
    // Struggle to find a more efficient method without regenerating the VM each time
    @State var serverVMCache: [UUID: ServerStatusVM] = [:]
    @State private var showingAddSheet = false
    @State private var showReleaseNotes = false
    @State var pendingDeepLink: String?
    @State private var showAlert = false
    @State var lastRefreshTime = Date()
    
    var body: some View {
        NavigationStack(path: $nav) {
            List {
                ForEach(servers ?? []) { vm in
                    NavigationLink(value: vm) {
                        ServerRow(vm)
                    }
                    .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                }
                .onDelete(perform: deleteItems)
                .onMove {
                    servers?.move(fromOffsets: $0, toOffset: $1)
                    
                    refreshDisplayOrders()
                }
            }
            .scrollIndicators(.never)
            .navigationDestination(for: ServerStatusVM.self) { vm in
                ServerDetails(vm) {
                    reloadData()
                    refreshDisplayOrders()
                }
            }
            .navigationDestination(for: PageDestinations.self) { destination in
                switch destination {
                case .SettingsRoot:
                    SettingsView {
                        reloadData(forceRefresh: true)
                    }
                }
            }
            .navigationDestination(for: SettingsPageDestinations.self) { destination in
                switch destination {
                case .GeneralSettings: GeneralSettings()
                case .FAQ:             FAQView(getiOSFAQs())
                case .Shortcuts:       ShortcutsGuide()
                case .Siri:            SiriGuide()
                case .WhatsNew:        ReleaseNotes(showDismissButton: false)
                }
            }
            .onOpenURL { url in
                print("Received deep link:", url)
                
                // Manually go into specific server if id is server
                if let serverUUID = UUID(uuidString: url.absoluteString), let vm = serverVMCache[serverUUID] {
                    goToServerView(vm)
                } else if !url.absoluteString.isEmpty {
                    pendingDeepLink = url.absoluteString
                }
            }
            .refreshable {
                reloadData(forceRefresh: true)
            }
            .overlay {
                //hack to avoid showing overlay for a split second before we have had a chance to check the database
                if let vms = servers, vms.isEmpty {
                    ContentUnavailableView {
                        Label("Add Your First Server", systemImage: "server.rack")
                    } description: {
                        Text("Use the button below or the \"+\" in the top right corner")
                    } actions: {
                        Button("Add Server") {
                            showingAddSheet = true
                        }
                        .semibold()
                        .buttonStyle(.borderedProminent)
                    }
                } else if servers == nil {
                    ProgressView()
                }
            }
            .navigationTitle("Servers")
            .toolbar {
#if os(macOS)
                ToolbarItem(placement: .navigation) {
                    NavigationLink(value: PageDestinations.SettingsRoot) {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItemGroup {
                    Button {
                        reloadData(forceRefresh: true)
                    } label: {
                        Label("Refresh Servers", systemImage: "arrow.clockwise")
                    }
                    
                    Button {
                        showingAddSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
#else // not macOS
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(value: PageDestinations.SettingsRoot) {
#if os(tvOS)
                        Text("Settings")
#else
                        Image(systemName: "gear")
#endif
                    }
                }
#if os(tvOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Refresh") {
                        reloadData(forceRefresh: true)
                    }
                }
#endif
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet.toggle()
                    } label: {
#if os(tvOS)
                        Text("+")
#else
                        Image(systemName: "plus")
#endif
                    }
                }
#endif
            }
        }
        .onChange(of: scenePhase, initial: true) { _, newPhase in
            // Some code to investigate an Apple Watch bug
            if newPhase == .active {
                print("Active")
                
                reloadData()
                checkForAutoReload()
                checkForAppReviewRequest()
                
            } else if newPhase == .inactive {
                print("Inactive")
                
            } else if newPhase == .background {
                print("Background")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)) { notification in
            guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else {
                return
            }
            
            // May have gotten new/changed data refresh models from db
            // Can we somehow check if anything actually changed?
            // This is spam called on every open
            if event.endDate != nil && event.type == .import {
                print("refresh triggered via eventChangedNotification")
                
                ShortcutsProvider.updateAppShortcutParameters()
                reloadData()
            }
        }
        .sheet($showingAddSheet) {
            // Create new binding server to add
            let newServer = SavedMinecraftServer.initialize(
                id: UUID(),
                serverType: .Java,
                name: "",
                serverUrl: "",
                serverPort: 0,
                srvServerUrl: "",
                srvServerPort: 0,
                serverIcon: "",
                displayOrder: 0
            )
            
            NavigationStack {
                EditServerView(newServer, isPresented: $showingAddSheet) {
                    // callback when server is edited or added
                    reloadData(forceSRVRefreh: true)
                    refreshDisplayOrders()
                }
            }
        }
        .sheet($showReleaseNotes) {
            NavigationStack {
                ReleaseNotes()
            }
        }
        .alert("Title", isPresented: $showAlert) {
            Button("OK") {
                showReleaseNotes = true
            }
        }
    }
    
    func reloadData(forceRefresh: Bool = false, forceSRVRefreh: Bool = false) {
        // crashes when run in background from apple watch??
        // FB13069019
        guard scenePhase != .background else {
            return
        }
        
        let fetch = FetchDescriptor<SavedMinecraftServer>(
            predicate: nil,
            sortBy: [.init(\.displayOrder)]
        )
        
        guard let results = try? modelContext.fetch(fetch) else {
            self.servers = []
            return
        }
        
        var config = ConfigHelper.getServerCheckerConfig()
        
        self.servers = results.map {
            if let cachedVm = serverVMCache[$0.id] {
                return cachedVm
            }
            
            // First time seeing this server
            // Force SRV refresh if needed
            config.forceSRVRefresh = forceSRVRefreh
            
            let vm = ServerStatusVM(
                modelContext: modelContext,
                server: $0
            )
            
            serverVMCache[$0.id] = vm
            
            if !forceRefresh {
                vm.reloadData(config)
            }
            
            return vm
        }
        
        if forceRefresh {
            self.lastRefreshTime = Date()
            
            self.servers?.forEach { vm in
                vm.reloadData(config)
            }
        }
        
        checkForPendingDeepLink()
    }
}

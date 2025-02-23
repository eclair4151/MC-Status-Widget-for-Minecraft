import SwiftUI
import SwiftData
import CoreData
import MCStatusDataLayer

enum PageDestinations {
    case SettingsRoot
}

struct MainAppContentView: View {
#if os(iOS)
    private let watchHelper = WatchHelper()
#endif
    @State private var nav = NavigationPath()
    
#if !os(tvOS)
    @Environment(\.requestReview) private var requestReview
#endif
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    
    @State private var serverVMs: [ServerStatusVM]?
    
    // I can't think of a better way to do this since I don't want to regenerate the VM every time
    @State private var serverVMCache: [UUID: ServerStatusVM] = [:]
    @State private var showingAddSheet = false
    @State private var showReleaseNotes = false
    @State private var lastRefreshTime = Date()
    @State private var pendingDeepLink: String?
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    private var reviewHelper = ReviewHelper()
    
    var body: some View {
        NavigationStack(path: $nav) {
            List {
                ForEach(serverVMs ?? []) { vm in
                    NavigationLink(value: vm) {
                        ServerRowView(vm)
                    }
                    .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                }
                .onMove {
                    serverVMs?.move(fromOffsets: $0, toOffset: $1)
                    
                    // update underlying display order
                    refreshDisplayOrders()
                }
                .onDelete(perform: deleteItems)
            }
            .scrollIndicators(.never)
            .navigationDestination(for: ServerStatusVM.self) { vm in
                ServerStatusDetailView(vm) {
                    reloadData()
                    refreshDisplayOrders()
                }
            }
            .navigationDestination(for: PageDestinations.self) { destination in
                switch destination {
                case .SettingsRoot:
                    SettingsRootView()
                }
            }
            .navigationDestination(for: SettingsPageDestinations.self) { destination in
                switch destination {
                case .GeneralSettings: GeneralSettings()
                case .FAQ:             FAQView(getiOSFAQs())
                case .Shortcuts:       ShortcutsGuideView()
                case .Siri:            SiriGuideView()
                case .WhatsNew:        ReleaseNotesView(showDismissButton: false)
                }
            }
            .onOpenURL { url in
                print("Received deep link: \(url)")
                
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
                if let vms = serverVMs, vms.isEmpty {
                    ContentUnavailableView {
                        Label("Add Your First Server", systemImage: "server.rack")
                    } description: {
                        Text("Add a server using the button below or the \"+\" in the top right corner")
                    } actions: {
                        Button("Add Server") {
                            showingAddSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if serverVMs == nil {
                    ProgressView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(value: PageDestinations.SettingsRoot) {
#if os(tvOS)
                        Text("Settings")
#else
                        Image(systemName: "gear")
#endif
                    }
                }
                
#if os(macOS) || os(tvOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        reloadData(forceRefresh: true)
                    } label: {
#if os(macOS)
                        Label("Refresh Servers", systemImage: "arrow.clockwise")
#elseif os(tvOS)
                        Text("Refresh")
#endif
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
            }
            .navigationTitle("Servers")
        }
        .onChange(of: scenePhase, initial: true) { old,newPhase in
            // this is some code to investigate an apple watch bug
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
            
            // May have gotten new/changed data refresh models from database
            // Can we somehow check if anything actually changed?
            // This is spam called on every open
            if event.endDate != nil && event.type == .import {
                print("refresh triggered via eventChangedNotification")
                
                MCStatusShortcutsProvider.updateAppShortcutParameters()
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
                ReleaseNotesView()
            }
        }
        .alert("Title", isPresented: $showAlert) {
            Button("OK") {
                showReleaseNotes = true
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func goToServerView(_ vm: ServerStatusVM) {
        // check if user has disabled deep links, if so just go to main list
        if !UserDefaultHelper.shared.get(for: .openToSpecificServer, defaultValue: true) {
            self.nav.removeLast(self.nav.count)
            return
        }
        
        // go to server view
        // first check if we are already showing a server, and if so, just update it
        if self.nav.isEmpty {
            self.nav.append(vm)
        } else {
            self.nav.removeLast(self.nav.count)
            
            Task {
                // hack! otherwise data wont refresh correctly
                self.nav.append(vm)
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        offsets.makeIterator().forEach { pos in
            if let serverVM = serverVMs?[pos] {
                modelContext.delete(serverVM.server)
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
        serverVMs?.remove(atOffsets: offsets)
    }
    
    private func refreshDisplayOrders() {
        serverVMs?.enumerated().forEach { index, vm in
            vm.server.displayOrder = index + 1
            modelContext.insert(vm.server)
        }
        
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func reloadData(forceRefresh: Bool = false, forceSRVRefreh: Bool = false) {
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
            self.serverVMs = []
            return
        }
        
        var config = ConfigHelper.getServerCheckerConfig()
        
        self.serverVMs = results.map {
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
            
            self.serverVMs?.forEach { vm in
                vm.reloadData(config)
            }
        }
        
        checkForPendingDeepLink()
    }
    
    private func checkForPendingDeepLink() {
        guard
            let pendingDeepLink,
            let serverID = UUID(uuidString: pendingDeepLink),
            let vm = serverVMCache[serverID]
        else {
            return
        }
        
        self.pendingDeepLink = nil
        goToServerView(vm)
    }
    
    private func checkForAutoReload() {
        let currentTime = Date()
        
        let timeInterval = currentTime.timeIntervalSince(lastRefreshTime)
        
        guard timeInterval > 60 else {
            return
        }
        
        // >60 seconds passed, reload servers and widgets
        reloadData(forceRefresh: true)
        
        refreshAllWidgets()
    }
    
    private func checkForAppReviewRequest() {
        reviewHelper.appLaunched()
        
        // dont show if they didn't add any servers
        if serverVMs?.isEmpty ?? true {
            return
        }
        
        if reviewHelper.shouldShowRequestView() {
            Task {
                try await Task.sleep(for: .seconds(6))
#if !os(tvOS)
                requestReview()
#endif
                reviewHelper.didShowReview()
            }
        }
    }
}

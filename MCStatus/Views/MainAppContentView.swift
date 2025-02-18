import SwiftUI
import SwiftData
import CloudKit
import CoreData
import MCStatusDataLayer
import WidgetKit
import StoreKit

enum PageDestinations {
    case SettingsRoot
}

struct MainAppContentView: View {
    private let watchHelper = WatchHelper()
    
    @Environment(\.requestReview) private var requestReview
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    
    @State private var serverVMs: [ServerStatusVM]?
    // i cant think of a better way to do this since i dont want to regenerate the view model every time
    @State private var serverVMCache: [UUID: ServerStatusVM] = [:]
    @State private var showingAddSheet = false
    @State private var showReleaseNotes = false
    @State private var lastRefreshTime = Date()
    @State private var navPath = NavigationPath()
    @State private var pendingDeepLink: String?
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    private var reviewHelper = ReviewHelper()
    
    var body: some View {
        NavigationStack(path: $navPath) {
            List {
                ForEach(serverVMs ?? []) { vm in
                    NavigationLink(value: vm) {
                        ServerRowView(vm: vm)
                    }
                    .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                }
                .onMove {
                    serverVMs?.move(fromOffsets: $0, toOffset: $1)
                    //update underlying display order
                    refreshDisplayOrders()
                }
                //                .onDelete(perform: deleteItems) // uncomment to enable swipe to delete. You can also use a custom Swipe Action instead of this to block full swipes and require partial swipe + tap
            }
            .navigationDestination(for: ServerStatusVM.self) { vm in
                ServerStatusDetailView(serverStatusVM: vm) {
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
                case .GeneralSettings: GeneralSettingsView()
                case .FAQ: FAQView(faqs: getiOSFAQs())
                case .Shortcuts: ShortcutsGuideView()
                case .Siri: SiriGuideView()
                case .WhatsNew: ReleaseNotesView(showDismissButton: false)
                }
            }
            .onOpenURL { url in
                print("Received deep link: \(url)")
                //manually go into specific server if id is server.
                if let serverUUID = UUID(uuidString: url.absoluteString), let vm = self.serverVMCache[serverUUID] {
                    goToServerView(vm: vm)
                } else if !url.absoluteString.isEmpty {
                    self.pendingDeepLink = url.absoluteString
                }
            }
            .refreshable {
                reloadData(forceRefresh: true)
            }
            .overlay {
                //hack to avoid showing overlay for a split second before we have had a chance to check the database
                if  let vms = self.serverVMs,  vms.isEmpty {
                    ContentUnavailableView {
                        Label("Add Your First Server", systemImage: "server.rack")
                    } description: {
                        Text("Let's get started! Add a server using the button below or the \"+\" in the top right corner.")
                    } actions: {
                        Button("Add Server") {
                            showingAddSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if self.serverVMs == nil {
                    ProgressView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(value: PageDestinations.SettingsRoot) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
#if targetEnvironment(macCatalyst) // Gross (show refresh button only on mac status bar since they can't pull to refresh)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        reloadData(forceRefresh: true)
                    } label: {
                        Label("Refresh Servers", systemImage: "arrow.clockwise")
                    }
                }
#endif
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet.toggle()
                    } label: {
                        Label("Add Item", systemImage: "plus")
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
            
            // may have gotten new/changed data refresh models from database
            // can we somehow check if anything actually changed? this is spam called on every open.
            if event.endDate != nil && event.type == .import {
                print("refresh triggered via eventChangedNotification")
                
                MCStatusShortcutsProvider.updateAppShortcutParameters()
                reloadData()
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            // create new binding server to add
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
                EditServerView(server: newServer, isPresented: $showingAddSheet) {
                    // callback when server is edited or added
                    reloadData(forceSRVRefreh: true)
                    refreshDisplayOrders()
                }
            }
        }
        .sheet(isPresented: $showReleaseNotes) {
            NavigationStack {
                ReleaseNotesView()
            }
        }
        .onAppear {
            let migrationResult = MigrationHelper.migrationIfNeeded()
            
            if let migrationResult {
                let old_v =  migrationResult.0
                let new_v = migrationResult.1
                
                if old_v == 0 && new_v >= 1 {
                    checkForBrokenWidgets()
                }
                
                // just migration to 2.0! check if showing error alert and show new stuff sheet
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(
                    Text("OK"),
                    action: {
                        showReleaseNotes = true
                    })
            )
        }
    }
    
    private func checkForBrokenWidgets() {
        WidgetCenter.shared.getCurrentConfigurations { result in
            switch result {
            case .success(let widgets):
                if widgets.isEmpty {
                    showReleaseNotes = true
                } else {
                    showWidgetWarning()
                }
                
            case .failure(let error):
                showReleaseNotes = true
                print(error)
            }
        }
    }
    
    private func showWidgetWarning() {
        alertTitle = "Widget Migration Notice!"
        alertMessage = "Due to a bug in iOS, widgets have been reset while migrating to the new App Intent System. (FB15531563). Simply edit your widget and re-select your server to fix them. Thank you for understanding! (I hope the new features make up for it!)"
        showAlert = true
    }
    
    private func goToServerView(vm: ServerStatusVM) {
        // check if user has disabled deep links, if so just go to main list
        if !UserDefaultHelper.shared.get(for: .openToSpecificServer, defaultValue: true) {
            self.navPath.removeLast(self.navPath.count)
            return
        }
        
        // go to server view
        // first check if we are already showing a server, and if so, just update it
        if self.navPath.isEmpty {
            self.navPath.append(vm)
        } else {
            self.navPath.removeLast(self.navPath.count)
            
            Task {
                // hack! otherwise data wont refresh correctly
                self.navPath.append(vm)
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
            // Try to save
            try modelContext.save()
        } catch {
            // We couldn't save :(
            print(error.localizedDescription)
        }
    }
    
    private func reloadData(forceRefresh:Bool = false, forceSRVRefreh:Bool = false) {
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
            
            //first time we are seeing this server. force srv refresh if needed.
            config.forceSRVRefresh = forceSRVRefreh
            let vm = ServerStatusVM(modelContext: self.modelContext, server: $0)
            serverVMCache[$0.id] = vm
            
            if !forceRefresh {
                vm.reloadData(config: config)
            }
            
            return vm
        }
        
        if forceRefresh {
            self.lastRefreshTime = Date()
            
            self.serverVMs?.forEach { vm in
                vm.reloadData(config: config)
            }
        }
        
        checkForPendingDeepLink()
    }
    
    private func checkForPendingDeepLink() {
        if let pendingDeepLink, let serverID = UUID(uuidString: pendingDeepLink), let vm = self.serverVMCache[serverID] {
            self.pendingDeepLink = nil
            goToServerView(vm: vm)
        }
    }
    
    private func checkForAutoReload() {
        let currentTime = Date()
        
        let timeInterval = currentTime.timeIntervalSince(lastRefreshTime)
        
        guard timeInterval > 60 else {
            return
        }
        
        // More than 60 seconds have passed, reload servers and widgets
        reloadData(forceRefresh: true)
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func checkForAppReviewRequest() {
        reviewHelper.appLaunched()
        
        // dont show if they didn't add any servers
        if self.serverVMs?.isEmpty ?? true {
            return
        }
        
        if reviewHelper.shouldShowRequestView() {
            Task {
                try await Task.sleep(for: .seconds(6))
                
                requestReview()
                reviewHelper.didShowReview()
            }
        }
    }
}

import SwiftUI
import SwiftData
import CloudKit
import CoreData
import WidgetKit
import MCStatsDataLayer

struct AppContainer: View {
    private enum iCloudStatus {
        case available, unavailable, unknown
    }
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) var modelContext
    
    @State var servers: [ServerStatusVM]?
    @State var lastRefreshTime = Date()
    @State private var serverVMCache: [UUID: ServerStatusVM] = [:]
    @State private var iCloudStatus: iCloudStatus = .unknown
    
    private var minSinceLastRefresh: Int {
        let currentTime = Date()
        let timeInterval = currentTime.timeIntervalSince(lastRefreshTime)
        
        return Int(timeInterval / 60)
    }
    
    private var statusChecker = WatchServerStatusChecker()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(servers ?? []) { vm in
                    NavigationLink(value: vm) {
                        ServerRow(vm)
                    }
                }
                .onDelete(perform: deleteItems)
                .onMove {
                    servers?.move(fromOffsets: $0, toOffset: $1)
                    
                    // update underlying display order
                    refreshDisplayOrders()
                }
                
                // Text("Updated \(minSinceLastRefresh)m ago")
                //     .frame(maxWidth: .infinity, alignment: .center)
                //     .listRowBackground(Color.clear) // this is ugly so removing it
            }
            .navigationDestination(for: ServerStatusVM.self) { vm in
                ServerDetails(vm) {
                    reloadData()
                    refreshDisplayOrders()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(value: PageDestinations.SettingsRoot) {
                        Label("Settings", systemImage: "gear")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        reloadData(forceRefresh: true)
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                            .foregroundColor(.white)
                        
                    }
                }
            }
            .navigationDestination(for: PageDestinations.self) { destination in
                switch destination {
                case .SettingsRoot:
                    SettingsView {
                        reloadData(forceRefresh: true)
                        refreshDisplayOrders()
                    }
                }
            }
            .overlay {
                if let servers, servers.isEmpty {
                    ContentUnavailableView("Add a Server", systemImage: "server.rack", description: Text("Servers are synced with your phone. This may take some time"))
                        .scrollDisabled(true)
                }
            }
        }
        .onChange(of: scenePhase, initial: true) { _, newPhase in
            // Some code to investigate an Apple Watch bug
            if newPhase == .active {
                print("Active")
                
                reloadData()
                checkForAutoReload()
                
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
            if event.endDate != nil && event.type == .import {
                reloadData()
                
                ShortcutsProvider.updateAppShortcutParameters()
                WidgetCenter.shared.invalidateConfigurationRecommendations()
            }
        }
        .onAppear {
            statusChecker.responseListener = { id, status in
                guard let servervVM = serverVMCache[id] else {
                    return
                }
                
                status.sortUsers()
                
                Task.detached { @MainActor in
                    servervVM.loadingStatus = .Finished
                    servervVM.status = status
                    servervVM.loadIcon()
                }
            }
            
            let container = CKContainer.default()
            
            container.accountStatus { accountStatus, error in
                switch accountStatus {
                case .available:
                    self.iCloudStatus = .available
                    
                case .noAccount, .restricted:
                    self.iCloudStatus = .unavailable
                    
                case .couldNotDetermine, .temporarilyUnavailable:
                    self.iCloudStatus = .unknown
                    
                @unknown default:
                    self.iCloudStatus = .unknown
                }
                
                if let error {
                    print("Error checking iCloud account status:", error.localizedDescription)
                }
            }
            
            //            let server = SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "OPBlocks", serverUrl: "hub.opblocks.com", serverPort: 25565)
            //            modelContext.insert(server)
            //            print(server.name)
            //
            //            modelContext.insert(server)
            
            ShortcutsProvider.updateAppShortcutParameters()
        }
    }
    
    func reloadData(forceRefresh: Bool = false) {
        let fetch = FetchDescriptor<SavedMinecraftServer>(
            predicate: nil,
            sortBy: [.init(\.displayOrder)]
        )
        
        guard let servers = try? modelContext.fetch(fetch) else {
            servers = []
            return
        }
        
        var serversToCheck: [SavedMinecraftServer] = []
        
        self.servers = servers.map {
            if let cachedVm = serverVMCache[$0.id] {
                return cachedVm
            }
            
            let vm = ServerStatusVM(modelContext: modelContext, server: $0)
            serverVMCache[$0.id] = vm
            
            if !forceRefresh {
                serversToCheck.append($0)
            }
            
            return vm
        }
        
        if forceRefresh {
            lastRefreshTime = Date()
            
            for vm in self.servers ?? [] {
                vm.loadingStatus = .Loading
            }
            
            serversToCheck = servers
        }
        
        guard !serversToCheck.isEmpty else {
            return
        }
        
        statusChecker.checkServers(serversToCheck)
    }
}

//#Preview {
//    AppContainer()
//}

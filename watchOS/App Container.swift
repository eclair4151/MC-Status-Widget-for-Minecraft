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
    @Environment(\.modelContext) private var modelContext
    
    @State private var servers: [ServerStatusVM]?
    @State private var serverVMCache: [UUID: ServerStatusVM] = [:]
    @State private var iCloudStatus: iCloudStatus = .unknown
    @State private var lastRefreshTime = Date()
    
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
                ServerDetails(vm)
            }
            .toolbar {
                if let servers, !servers.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Servers")
                            .fontSize(25)
                            .bold()
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
        }
        .overlay {
            if let servers, servers.isEmpty {
                VStack {
                    Spacer()
                    
                    Image(systemName: "server.rack")
                        .fontSize(30)
                        .foregroundStyle(.gray)
                    
                    ContentUnavailableView("Add a Server", systemImage: "", description: Text("Servers are synced with your phone. This may take some time"))
                        .scrollDisabled(true)
                    
                    Spacer()
                }
            }
        }
        .onChange(of: scenePhase, initial: true) { _, newPhase in
            // Some code to investigate an apple watch bug
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
                MCStatsShortcutsProvider.updateAppShortcutParameters()
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
            
            MCStatsShortcutsProvider.updateAppShortcutParameters()
        }
    }
    
    private func checkForAutoReload() {
        let currentTime = Date()
        
        let timeInterval = currentTime.timeIntervalSince(lastRefreshTime)
        
        guard timeInterval > 60 else {
            return
        }
        
        // More than 60 seconds have passed, call the desired method
        reloadData(forceRefresh: true)
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func reloadData(forceRefresh: Bool = false) {
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
    
    private func deleteItems(at offsets: IndexSet) {
        offsets.makeIterator().forEach { pos in
            if let serverVM = servers?[pos] {
                modelContext.delete(serverVM.server)
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
        servers?.remove(atOffsets: offsets)
    }
    
    private func refreshDisplayOrders() {
        servers?.enumerated().forEach { index, vm in
            vm.server.displayOrder = index + 1
            modelContext.insert(vm.server)
        }
        
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

//#Preview {
//    AppContainer()
//}

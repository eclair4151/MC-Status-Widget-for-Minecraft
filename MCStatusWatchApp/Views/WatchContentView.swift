//
//  WatchContentView.swift
//  MCStatusWatchApp Watch App
//
//  Created by Tomer Shemesh on 8/7/23.
//

import SwiftUI
import SwiftData
import CloudKit
import CoreData
import MCStatusDataLayer

//func testServer() -> SavedMinecraftServer {
//    return SavedMinecraftServer(id: UUID(), serverType: .Java, name: "Hodor", serverUrl: "zero.minr.org", serverPort: 25565)
//}


struct WatchContentView: View {
    private enum iCloudStatus {
        case available, unavailable, unknown
    }
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.modelContext) private var modelContext
    @State private var serverViewModels: [ServerStatusViewModel] = []
    @State private var serverViewModelCache: [UUID:ServerStatusViewModel] = [:]
    @State private var iCloudStatus: iCloudStatus = .unknown
    @State private var lastRefreshTime = Date()
    private var minSinceLastRefresh: Int {
        let currentTime = Date()
        let timeInterval = currentTime.timeIntervalSince(lastRefreshTime)
        return Int(timeInterval / 60)
    }
    var statusChecker = WatchServerStatusChecker()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(serverViewModels) { viewModel in
                    NavigationLink(value: viewModel) {
                        WatchServerRowView(viewModel: viewModel)
                    }
                }
//                Text("Updated \(minSinceLastRefresh)m ago").frame(maxWidth: .infinity, alignment: .center).listRowBackground(Color.clear) // this is ugly so removing it
            }.navigationDestination(for: ServerStatusViewModel.self) { viewModel in
                WatchServerDetailScreen(serverStatusViewModel: viewModel)
            }
            .toolbar {
                if !serverViewModels.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Servers").font(.system(size: 25)).bold()
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
        }
        
        .overlay {
            if self.iCloudStatus == .unavailable && serverViewModels.isEmpty {
                VStack {
                    Spacer()
                    Image (systemName: "icloud.slash")
                    .font (.system(size: 30))
                    .foregroundStyle(.gray)
                    ContentUnavailableView("Enable iCloud", systemImage: "",
                       description: Text ("iCloud is required to sync servers to your watch."))
                    .scrollDisabled(true)
                    Spacer()
                }
            } else if serverViewModels.isEmpty {
                VStack {
                    Spacer()
                    Image (systemName: "server.rack")
                    .font (.system(size: 30))
                    .foregroundStyle(.gray)
                    ContentUnavailableView("Add a Server", systemImage: "",
                       description: Text ("Let's get started! Add a server using your phone."))
                    .scrollDisabled(true)
                    Spacer()
                }
            }
        }
        .onChange(of: scenePhase, initial: true) { old,newPhase in
            // this is some code to investigate an apple watch bug
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
                MCStatusShortcutsProvider.updateAppShortcutParameters()
            }
        }.onAppear {
            statusChecker.responseListener = { id, status in
                guard let servervVM = self.serverViewModelCache[id] else {
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
                
                if let error = error {
                    print("Error checking iCloud account status: \(error.localizedDescription)")
                }
            }
            
//            let server = SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "OPBlocks", serverUrl: "hub.opblocks.com", serverPort: 25565)
//            modelContext.insert(server)
//            print(server.name)
//            
//            modelContext.insert(server)
            MCStatusShortcutsProvider.updateAppShortcutParameters()
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
    }
    
    private func reloadData(forceRefresh:Bool = false) {
        let fetch = FetchDescriptor<SavedMinecraftServer>(
            predicate: nil,
            sortBy: [.init(\.displayOrder)]
        )
        guard let servers = try? modelContext.fetch(fetch) else {
            self.serverViewModels = []
            return
        }
        
        var serversToCheck:[SavedMinecraftServer] = []
        
        self.serverViewModels = servers.map {
            if let cachedVm = serverViewModelCache[$0.id] {
                return cachedVm
            }
            
            let vm = ServerStatusViewModel(modelContext: self.modelContext, server: $0)
            serverViewModelCache[$0.id] = vm
            if !forceRefresh {
                serversToCheck.append($0)
            }
            return vm
        }
        
        if forceRefresh {
            lastRefreshTime = Date()
            for vm in self.serverViewModels {
                vm.loadingStatus = .Loading
            }
            serversToCheck = servers
        }
        
        guard !serversToCheck.isEmpty else {
            return
        }
        
        statusChecker.checkServers(servers: serversToCheck)
    }
}
//
//#Preview {
//    WatchContentView()
//}

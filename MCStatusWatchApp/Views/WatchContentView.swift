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
    
    @Environment(\.modelContext) private var modelContext
    @State private var serverViewModels: [ServerStatusViewModel] = []
    @State private var serverViewModelCache: [UUID:ServerStatusViewModel] = [:]
    
    var statusChecker = WatchServerStatusChecker()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(serverViewModels) { viewModel in
                    NavigationLink(value: viewModel) {
                        WatchServerRowView(viewModel: viewModel)
                    }
                }

            }.navigationDestination(for: ServerStatusViewModel.self) { viewModel in
                WatchServerDetailScreen(serverStatusViewModel: viewModel)
            }
            .toolbar {
                if !serverViewModels.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            reloadData(forceRefresh: true)
                        } label: {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                    }
                }
            }
        }
        .overlay {
            if !isICloudEnabled() && serverViewModels.isEmpty {
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
                
                servervVM.status = status
                servervVM.loadIcon()
            }
//            let server = SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Harmony Server", serverUrl: "join.harmonyfallssmp.world", serverPort: 25565)
//            modelContext.insert(server)
//            print(server.name)
//            
//            modelContext.insert(server)
            reloadData()
            MCStatusShortcutsProvider.updateAppShortcutParameters()
        }
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
            serversToCheck = servers
        }
        
        guard !serversToCheck.isEmpty else {
            return
        }
        
        statusChecker.checkServers(servers: serversToCheck)
    }
    
    private func isICloudEnabled() -> Bool {
        return FileManager.default.ubiquityIdentityToken != nil
    }
}
//
//#Preview {
//    WatchContentView()
//}

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


func testServer() -> SavedMinecraftServer {
    return SavedMinecraftServer(id: UUID(), serverType: .Java, name: "Hodor", serverUrl: "zero.minr.org", serverPort: 25565)
}

struct WatchContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var serverViewModels: [ServerStatusViewModel] = []
    @State private var serverViewModelCache: [UUID:ServerStatusViewModel] = [:]
    
    var statusChecker = WatchServerStatusChecker()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(serverViewModels) { viewModel in
                    NavigationLink {
                        // add detail screen here
                    }
                    label: {
                        if let status = viewModel.status {
                            Text(viewModel.server.name + " - " + status.getDisplayText())
                        } else {
                            Text(viewModel.server.name + " - " + viewModel.loadingStatus.rawValue)
                        }
                    }
                }

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
            if serverViewModels.isEmpty {
                VStack {
                    Spacer()
                    Image (systemName: "server.rack")
                    .font (.system(size: 30))
                    .foregroundStyle(.gray)
                    ContentUnavailableView("Add a Server", systemImage: "",
                       description: Text ("Let's get started! Add a server using your phone."))
                    .scrollDisabled(true)
                    Spacer()
                }.padding()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)) { notification in
            guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else {
                return
            }
            
            // may have gotten new/changed data refresh models from database
            if event.endDate != nil && event.type == .import {
                reloadData()
            }
        }.onAppear {
            statusChecker.responseListener = { id, status in
                guard let servervVM = self.serverViewModelCache[id] else {
                    return
                }
                
                servervVM.status = status
            }
            reloadData()
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
            
            let vm = ServerStatusViewModel(server: $0)
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
}

//#Preview {
//    ContentView()
//}

//
//  ContentView.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 6/27/23.
//

import SwiftUI
import SwiftData
import CloudKit
import CoreData

struct MainAppContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var serverViewModels: [ServerStatusViewModel] = []
    // i cant think of a better way to do this since i dont want to regenerate the view model every time
    @State private var serverViewModelCache: [UUID:ServerStatusViewModel] = [:]
    @State private var showingAddSheet = false

    var body: some View {
        NavigationView {
            List {
                ForEach(serverViewModels) { viewModel in
                    NavigationLink {
                        ServerStatusDetailView(serverStatusViewModel: viewModel) {
                            reloadData()
                            refreshDisplayOrders()
                        }
                    }
                    label: {
                        if let status = viewModel.status {
                            Text(viewModel.server.name! + " - " + status.getDisplayText())
                        } else {
                            Text(viewModel.server.name! + " - " + viewModel.loadingStatus.rawValue)
                        }
                    }
                }
                .onMove {
                    serverViewModels.move(fromOffsets: $0, toOffset: $1)
                    //update underlying display order
                    refreshDisplayOrders()
                }
                //.onDelete(perform: deleteItems) // uncomment to enable swipe to delete. You can also use a custom Swipe Action instead of this to block full swipes and require partial swipe + tap
            }.refreshable {
                reloadData(forceRefresh: true)
            }.overlay {
                if serverViewModels.isEmpty {
                    ContentUnavailableView {
                        Label("Add Your First Server", systemImage: "server.rack")
                    } description: {
                        Text("Let's get started! Add a server using the button below or the \"+\" button in the top right corner.")
                    } actions: {
                        Button("Add Server") {
                            showingAddSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }.toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: SettingsRootView()) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet.toggle()
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }.onAppear {
            reloadData()
        }.onReceive(NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)) { notification in
            guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else {
                return
            }
            
            // may have gotten new/changed data refresh models from database
            if event.endDate != nil && event.type == .import {
                reloadData()
            }
        }.sheet(isPresented: $showingAddSheet) {
            // create new binding server to add
            let newServer = SavedMinecraftServer(id: UUID(), serverType: .Java, name: "", serverUrl: "", serverPort: 25565, srvServerUrl: "", srvServerPort: 0, serverIcon: "", displayOrder: 0)
            NavigationView {
                EditServerView(server: newServer, isPresented: $showingAddSheet) {
                    reloadData()
                    refreshDisplayOrders()
                }
            }.interactiveDismissDisabled()
        }
    }


    
    
    private func refreshDisplayOrders() {
        serverViewModels.enumerated().forEach { index, vm in
            vm.server.displayOrder = index + 1
        }
    }
    private func reloadData(forceRefresh:Bool = false) {
        let fetch = FetchDescriptor<SavedMinecraftServer>(
            predicate: nil,
            sortBy: [.init(\.displayOrder)]
        )
        guard let results = try? modelContext.fetch(fetch) else {
            self.serverViewModels = []
            return
        }
        
        self.serverViewModels = results.map {
            if let cachedVm = serverViewModelCache[$0.id!] {
                return cachedVm
            }
            
            let vm = ServerStatusViewModel(server: $0)
            serverViewModelCache[$0.id!] = vm
            if !forceRefresh {
                vm.reloadData()
            }
            return vm
        }
        
        if forceRefresh {
            self.serverViewModels.forEach { vm in
                vm.reloadData()
            }
        }
    }
    
}


//
//#Preview {
//    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
//}

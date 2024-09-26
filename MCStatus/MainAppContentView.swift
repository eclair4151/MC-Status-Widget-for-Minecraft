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
import MCStatusDataLayer

//import MCStatusAppIntentsExtension




struct MainAppContentView: View {
    
    let watchHelper = WatchHelper()
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.modelContext) private var modelContext
    @State private var serverViewModels: [ServerStatusViewModel]?
    // i cant think of a better way to do this since i dont want to regenerate the view model every time
    @State private var serverViewModelCache: [UUID:ServerStatusViewModel] = [:]
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(serverViewModels ?? []) { viewModel in
                    NavigationLink {
                        ServerStatusDetailView(serverStatusViewModel: viewModel) {
                            reloadData()
                            refreshDisplayOrders()
                        }
                    }
                    label: {
                        if let status = viewModel.status {
//                            Text(viewModel.server.name + " - " + status.getDisplayText())
                            ServerRowView(title: viewModel.server.name, subtitle: status.getDisplayText())
                        } else {
//                            Text(viewModel.server.name + " - " + viewModel.loadingStatus.rawValue)
                            ServerRowView(title: viewModel.server.name, subtitle: viewModel.loadingStatus.rawValue)

                        }
                    }
                }
                .onMove {
                    serverViewModels?.move(fromOffsets: $0, toOffset: $1)
                    //update underlying display order
                    refreshDisplayOrders()
                }
                //.onDelete(perform: deleteItems) // uncomment to enable swipe to delete. You can also use a custom Swipe Action instead of this to block full swipes and require partial swipe + tap
            }.refreshable {
                reloadData(forceRefresh: true)
            }.overlay {
                //hack to avoid showing overlay for a split second before we have had a chance to check the database
                if  let viewModels = self.serverViewModels,  viewModels.isEmpty {
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
//                        testCall()
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
        .onChange(of: scenePhase, initial: true) { old,newPhase in
            // this is some code to investigate an apple watch bug
            if newPhase == .active {
                print("Active")
                reloadData()
            } else if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .background {
                print("Background")
            }
        }
        .onAppear {
            reloadData()
        }.onReceive(NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)) { notification in
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
        }.sheet(isPresented: $showingAddSheet) {
            // create new binding server to add
            let newServer = SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "", serverUrl: "", serverPort: 0, srvServerUrl: "", srvServerPort: 0, serverIcon: "", displayOrder: 0)
            NavigationView {
                EditServerView(server: newServer, isPresented: $showingAddSheet) {
                    reloadData()
                    refreshDisplayOrders()
                }
            }
        }
    }
    
    
    private func refreshDisplayOrders() {
        serverViewModels?.enumerated().forEach { index, vm in
            vm.server.displayOrder = index + 1
        }
    }
    
    
    private func reloadData(forceRefresh:Bool = false) {        
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
            self.serverViewModels = []
            return
        }
        
        self.serverViewModels = results.map {
            if let cachedVm = serverViewModelCache[$0.id] {
                return cachedVm
            }
            
            let vm = ServerStatusViewModel(server: $0)
            serverViewModelCache[$0.id] = vm
            if !forceRefresh {
                vm.reloadData()
            }
            return vm
        }
                
        if forceRefresh {
            self.serverViewModels?.forEach { vm in
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

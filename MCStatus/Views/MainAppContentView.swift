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
import WidgetKit
import StoreKit

enum PageDestinations {
    case SettingsRoot
}
struct MainAppContentView: View {
    
    let watchHelper = WatchHelper()
    
    @Environment(\.requestReview) private var requestReview
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.modelContext) private var modelContext
    @State private var serverViewModels: [ServerStatusViewModel]?
    // i cant think of a better way to do this since i dont want to regenerate the view model every time
    @State private var serverViewModelCache: [UUID:ServerStatusViewModel] = [:]
    @State private var showingAddSheet = false
    @State private var lastRefreshTime = Date()
    @State private var navPath = NavigationPath()
    @State private var pendingDeepLink: String?
    private var reviewHelper = ReviewHelper()
    
    var body: some View {
        NavigationStack(path: $navPath) {
            List {
                ForEach(serverViewModels ?? []) { viewModel in
                    NavigationLink(value: viewModel) {
                        ServerRowView(viewModel: viewModel)
                    }.listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                }
                .onMove {
                    serverViewModels?.move(fromOffsets: $0, toOffset: $1)
                    //update underlying display order
                    refreshDisplayOrders()
                }
//                .onDelete(perform: deleteItems) // uncomment to enable swipe to delete. You can also use a custom Swipe Action instead of this to block full swipes and require partial swipe + tap
            }.navigationDestination(for: ServerStatusViewModel.self) { viewModel in
                ServerStatusDetailView(serverStatusViewModel: viewModel) {
                    reloadData()
                    refreshDisplayOrders()
                }
            }.navigationDestination(for: PageDestinations.self) { destination in
                switch destination {
                case .SettingsRoot:
                    SettingsRootView()
                }
            }.navigationDestination(for: SettingsPageDestinations.self) { destination in
                switch destination {
                    case .GeneralSettings: GeneralSettingsView()
                    case .FAQ: FAQView(faqs: getiOSFAQs())
                    case .Shortcuts: ShortcutsView()
                    case .Siri: SiriSettingsView()
                }
            }.onOpenURL { url in
                print("Received deep link: \(url)")
                //manually go into specific server if id is server.
                if let serverUUID = UUID(uuidString: url.absoluteString), let vm = self.serverViewModelCache[serverUUID] {
                    goToServerView(viewModel: vm)
                } else if !url.absoluteString.isEmpty {
                    self.pendingDeepLink = url.absoluteString
                }
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
            }.navigationTitle("Servers")
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
                    // callback when server is edited or added
                    reloadData(forceSRVRefreh: true)
                    refreshDisplayOrders()
                }
            }
        }
    }
    
    private func goToServerView(viewModel: ServerStatusViewModel) {
        // go to server view.
        // first check if we are already showing a server, and if so, just update it.
        if !self.navPath.isEmpty {
            self.navPath.removeLast(self.navPath.count)
            Task {
                // hack! otherwise data wont refresh correctly
                self.navPath.append(viewModel)
            }
        } else {
            self.navPath.append(viewModel)
        }
        
    }
    
    private func deleteItems(at offsets: IndexSet) {
        offsets.makeIterator().forEach { pos in
            if let serverViewModel = serverViewModels?[pos] {
                modelContext.delete(serverViewModel.server)
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
        serverViewModels?.remove(atOffsets: offsets)
    }
    
    
    private func refreshDisplayOrders() {
        serverViewModels?.enumerated().forEach { index, vm in
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
            self.serverViewModels = []
            return
        }
        
        var config = ConfigHelper.getServerCheckerConfig()
        self.serverViewModels = results.map {
            if let cachedVm = serverViewModelCache[$0.id] {
                return cachedVm
            }
            
            //first time we are seeing this server. force srv refresh if needed.
            config.forceSRVRefresh = forceSRVRefreh
            let vm = ServerStatusViewModel(modelContext: self.modelContext, server: $0)
            serverViewModelCache[$0.id] = vm
            if !forceRefresh {
                vm.reloadData(config: config)
            }
            return vm
        }
                
        if forceRefresh {
            self.lastRefreshTime = Date()
            self.serverViewModels?.forEach { vm in
                vm.reloadData(config: config)
            }
        }
        checkForPendingDeepLink()
    }
    
    private func checkForPendingDeepLink() {
        if let pendingDeepLink, let serverID = UUID(uuidString: pendingDeepLink), let vm = self.serverViewModelCache[serverID] {
            self.pendingDeepLink = nil
            goToServerView(viewModel: vm)
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
        // dont show if they didnt add any servers
        if self.serverViewModels?.isEmpty ?? true {
            return
        }
        if reviewHelper.shouldShowRequestView() {
            Task {
                try await Task.sleep(for: .seconds(8))
                requestReview()
                reviewHelper.didShowReview()
            }
            
        }
    }
    
}

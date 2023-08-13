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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(serverViewModels) { viewModel in
                    NavigationLink {
                        ServerStatusDetailView(serverStatusViewModel: viewModel)
                    }
//                    .refreshable {
////
//                    }
                    label: {
                        Text(viewModel.server.name! + " - " + (viewModel.status?.status.rawValue ?? "Loading"))
                    }
                }
                .onDelete(perform: deleteItems)
            }.refreshable {
                reloadData(forceRefresh: true)
            }.toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }.onAppear {
            reloadData()
        }.onReceive(NotificationCenter.default.publisher(
            for: NSPersistentCloudKitContainer.eventChangedNotification
        )) { notification in
            guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else {
                return
            }
            if event.endDate != nil && event.type == .import {
                reloadData()
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = SavedMinecraftServer(id:UUID(), serverType: .Java, name: "tomer's Server", serverUrl: "192.168.4.72", serverPort: 25565)
            modelContext.insert(newItem)
            do {
                // Try to save
                try modelContext.save()
            } catch {
                // We couldn't save :(
                // Failures include issues such as an invalid unique constraint
                print(error.localizedDescription)
            }
            reloadData()
            print("added server")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(serverViewModels[index].server)
                do {
                    // Try to save
                    try modelContext.save()
                } catch {
                    // We couldn't save :(
                    // Failures include issues such as an invalid unique constraint
                    print(error.localizedDescription)
                }
                reloadData()
            }
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

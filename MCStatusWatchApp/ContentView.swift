//
//  ContentView.swift
//  MCStatusWatchApp Watch App
//
//  Created by Tomer Shemesh on 8/7/23.
//

import SwiftUI
import SwiftData
import CloudKit
import CoreData

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext

    let connectivityProvider = ConnectivityProvider()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, hodor!")
            Button("Send") {
//                connectivityProvider.send(message: [:])
                reloadData()
            }
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)) { notification in
            guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else {
                return
            }
            
            // may have gotten new/changed data refresh models from database
            if event.endDate != nil && event.type == .import {
                reloadData()
            }
        }
    }
    
    private func reloadData() {
        let fetch = FetchDescriptor<SavedMinecraftServer>(
            predicate: nil,
            sortBy: [.init(\.displayOrder)]
        )
        guard let results = try? modelContext.fetch(fetch) else {
            return
        }
        
        print(results.count)
    }
}

//#Preview {
//    ContentView()
//}

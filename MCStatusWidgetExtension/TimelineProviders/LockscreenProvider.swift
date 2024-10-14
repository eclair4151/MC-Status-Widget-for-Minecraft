//
//  LockscreenProvider.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 10/11/24.
//
import WidgetKit
import MCStatusDataLayer
import UIKit
import SwiftData


struct LockscreenProvider: AppIntentTimelineProvider {
    
    let widgetType: LSWidgetType
    
    init(widgetType: LSWidgetType) {
        self.widgetType = widgetType
    }
//    
//    func recommendations() -> [AppIntentRecommendation<ServerSelectNoThemeWidgetIntent>] {
//        // for some reason i need this hack because this moethod doesnt support async/await
//        let semaphore = DispatchSemaphore(value: 0)
//        var results: [AppIntentRecommendation<ServerSelectNoThemeWidgetIntent>] = []
//        Task {
//            // load all servers and make suggestions for all of them
//            let container = SwiftDataHelper.getModelContainter()
//            let servers = await SwiftDataHelper.getSavedServers(container: container)
//            
//            results = servers.map {
//                let entity = ServerIntentTypeAppEntity(id: $0.id.uuidString, displayString: $0.name)
//                let intent = ServerSelectNoThemeWidgetIntent()
//                intent.Server = entity
//                let widgetNamePostfix = if self.widgetType == .OnlyImage {
//                    " - Image Only!"
//                } else {
//                    ""
//                }
//                
//                let watchComplicationName = $0.name + widgetNamePostfix
//                return AppIntentRecommendation(intent: intent, description: watchComplicationName)
//            }
//            semaphore.signal()
//        }
//        
//        // Wait for the async task to complete
//        semaphore.wait()
//        
//        return results
//    }
    
    func recommendations() -> [AppIntentRecommendation<ServerSelectNoThemeWidgetIntent>] {
        
        let entity = ServerIntentTypeAppEntity(id: "BE036AAF-8E90-4629-8642-F6F749D6E9A9", displayString: "Zero Server")
       let intent = ServerSelectNoThemeWidgetIntent()
       intent.Server = entity
        let widgetNamePostfix = if self.widgetType == .OnlyImage {
            " - Image Only"
        } else {
            ""
        }

        let watchComplicationName = "Zero's Test2" + widgetNamePostfix
        return [AppIntentRecommendation(intent: intent, description: watchComplicationName)]
    }
    
    // this view is for when the widget has been added the the homescreen, but the user has not selected a server/theme ? or not.
    func placeholder(in context: Context) -> ServerStatusLSSnapshotEntry {
        var vm = WidgetEntryViewModel()
        vm.setForUnconfiguredView()
        return ServerStatusLSSnapshotEntry(date: Date(), configuration: ServerSelectNoThemeWidgetIntent(), viewModel: vm)
    }
    
    // is context.isPreview is true, this is the view to show when someone clicked add widget. Just show preview with placeholder data. if it is false, yo ushould actually load the current state of the view by getting the status
    func snapshot(for configuration: ServerSelectNoThemeWidgetIntent, in context: Context) async -> ServerStatusLSSnapshotEntry {
        var vm = WidgetEntryViewModel()
        
        let container = SwiftDataHelper.getModelContainter()
        if !context.isPreview, let (server, serverStatus) = await loadTimelineData(container: container, configuration: configuration) {
            let serverIcon = ImageHelper.convertFavIconString(favIcon: serverStatus.favIcon) ?? UIImage(named: "DefaultIcon")!
            vm = WidgetEntryViewModel(serverName: server.name, status: serverStatus, lastUpdated: "now", serverIcon: serverIcon, theme: .auto)
        }
        return ServerStatusLSSnapshotEntry(date: Date(), configuration: configuration, viewModel: vm)
    }
    
    
    func loadTimelineData(container: ModelContainer, configuration: ServerSelectNoThemeWidgetIntent) async -> (SavedMinecraftServer, ServerStatus)? {
        // step 1 load server from DB
        guard let serverId = configuration.Server?.id,
              let uuid = UUID(uuidString: serverId),
              let server = await SwiftDataHelper.getSavedServerById(container: container, server_id: uuid) else {
            return nil
        }

        // step 2 load status
        //horrible hack to handle watch vs phone
        #if os(watchOS)
        let statusResult = await WatchServerStatusChecker().checkServerAsync(server: server)
        #else
        let statusResult = await ServerStatusChecker.checkServer(server: server)
        #endif
        
        return (server, statusResult)
    }
    
    
    
    func timeline(for configuration: ServerSelectNoThemeWidgetIntent, in context: Context) async -> Timeline<ServerStatusLSSnapshotEntry> {
        var entries: [ServerStatusLSSnapshotEntry] = []
        let currentDate = Date()
        let futureDate = Calendar.current.date(byAdding: .minute, value: 10, to: Date())!

        let container = SwiftDataHelper.getModelContainter()
        guard let (server, serverStatus) = await loadTimelineData(container: container, configuration: configuration) else {
            // nothing configured yet?
            var vm = WidgetEntryViewModel()
            vm.setForUnconfiguredView()
            let entry = ServerStatusLSSnapshotEntry(date: currentDate, configuration: configuration, viewModel: vm)
            entries.append(entry)
            
            return Timeline(entries: entries, policy: .after(futureDate))
        }
        let serverIcon = ImageHelper.convertFavIconString(favIcon: serverStatus.favIcon) ?? UIImage(named: "DefaultIcon")!
        
        let vm = WidgetEntryViewModel(serverName: server.name, status: serverStatus, lastUpdated: "", serverIcon: serverIcon, theme: .auto)
        let entry = ServerStatusLSSnapshotEntry(date: currentDate, configuration: configuration, viewModel: vm)
        entries.append(entry)
        
        return Timeline(entries: entries, policy: .after(futureDate))
    }
}

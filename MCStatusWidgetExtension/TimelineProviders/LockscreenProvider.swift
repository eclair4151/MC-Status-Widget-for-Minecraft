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

    // This is needed for apple watch complications
    func recommendations() -> [AppIntentRecommendation<ServerSelectNoThemeWidgetIntent>] {
        let container = SwiftDataHelper.getModelContainter()
        let servers = SwiftDataHelper.getSavedServersBg(container: container)
        
        return servers.map {
           let entity = ServerIntentTypeAppEntity(id: $0.id.uuidString, displayString: $0.name)
           let intent = ServerSelectNoThemeWidgetIntent()
           intent.Server = entity
           let widgetNamePostfix = if self.widgetType == .OnlyImage {
               " (No Text)"
           } else {
               ""
           }

           let watchComplicationName = $0.name + widgetNamePostfix
           return AppIntentRecommendation(intent: intent, description: watchComplicationName)
       }
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
        
        if (context.isPreview) {
            vm.viewType = .Preview
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
            let serverCount = await SwiftDataHelper.getSavedServers(container: container).count
            if serverCount == 0 {
                // if user has nothing in the db tell them to open the app
                vm.serverName = "Open App"
            }
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

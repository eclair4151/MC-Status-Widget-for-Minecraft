//
//  HomescreenProvider.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 10/11/24.
//

import WidgetKit
import MCStatusDataLayer
import UIKit
import SwiftData


struct HomescreenProvider: AppIntentTimelineProvider {
    // this view is for when the widget has been added the the homescreen, but the user has not selected a server/theme ? or not.
    func placeholder(in context: Context) -> ServerStatusHSSnapshotEntry {
        var vm = WidgetEntryViewModel()
        vm.setForUnconfiguredView()
        return ServerStatusHSSnapshotEntry(date: Date(), configuration: ServerSelectWidgetIntent(), viewModel: vm)
    }
    
    // is context.isPreview is true, this is the view to show when someone clicked add widget. Just show preview with placeholder data. if it is false, yo ushould actually load the current state of the view by getting the status
    func snapshot(for configuration: ServerSelectWidgetIntent, in context: Context) async -> ServerStatusHSSnapshotEntry {
        var vm = WidgetEntryViewModel()
        
        let container = SwiftDataHelper.getModelContainter()
        if !context.isPreview, let (server, serverStatus, widgetTheme) = await loadTimelineData(container: container, configuration: configuration) {
            let serverIcon = ImageHelper.convertFavIconString(favIcon: serverStatus.favIcon) ?? UIImage(named: "DefaultIcon")!
            vm = WidgetEntryViewModel(serverName: server.name, status: serverStatus, lastUpdated: "now", serverIcon: serverIcon, theme: widgetTheme)
        }
        return ServerStatusHSSnapshotEntry(date: Date(), configuration: configuration, viewModel: vm)
    }
    
    
    func loadTimelineData(container: ModelContainer, configuration: ServerSelectWidgetIntent) async -> (SavedMinecraftServer, ServerStatus, Theme)? {
        // step 1 load server from DB
        guard let serverId = configuration.Server?.id,
              let uuid = UUID(uuidString: serverId),
              let server = await SwiftDataHelper.getSavedServerById(container: container, server_id: uuid) else {
            return nil
        }

        // step 2 load status
        let statusResult = await ServerStatusChecker.checkServer(server: server)
        let theme = if let themeId = configuration.Theme?.id, let themeEnum = Theme(rawValue: themeId) {
            themeEnum
        } else {
            Theme.auto
        }
        
        return (server, statusResult, theme)
    }
    
    
    
    func timeline(for configuration: ServerSelectWidgetIntent, in context: Context) async -> Timeline<ServerStatusHSSnapshotEntry> {
        var entries: [ServerStatusHSSnapshotEntry] = []
        let currentDate = Date()
        let futureDate = Calendar.current.date(byAdding: .minute, value: 10, to: Date())!

        let container = SwiftDataHelper.getModelContainter()
        guard let (server, serverStatus, widgetTheme) = await loadTimelineData(container: container, configuration: configuration) else {
            // nothing configured yet?
            var vm = WidgetEntryViewModel()
            vm.setForUnconfiguredView()
            let entry = ServerStatusHSSnapshotEntry(date: currentDate, configuration: configuration, viewModel: vm)
            entries.append(entry)
            
            return Timeline(entries: entries, policy: .after(futureDate))
        }
        let serverIcon = ImageHelper.convertFavIconString(favIcon: serverStatus.favIcon) ?? UIImage(named: "DefaultIcon")!
        
        for minOffset in 0 ..< 15 {
            var timeStr = ""
            if (minOffset == 0) {
                timeStr = "now"
            } else {
                timeStr = "\(minOffset)m ago"
            }
            
            let vm = WidgetEntryViewModel(serverName: server.name, status: serverStatus, lastUpdated: timeStr, serverIcon: serverIcon, theme: widgetTheme)
            let entryDate = Calendar.current.date(byAdding: .minute, value: minOffset, to: currentDate)!
            let entry = ServerStatusHSSnapshotEntry(date: entryDate, configuration: configuration, viewModel: vm)
            entries.append(entry)
        }
        
        for minOffset in stride(from: 15, through: 55, by: 5) {
            let timeStr = "\(minOffset)m ago"
            let vm = WidgetEntryViewModel(serverName: server.name, status: serverStatus, lastUpdated: timeStr, serverIcon: serverIcon, theme: widgetTheme)
            let entryDate = Calendar.current.date(byAdding: .minute, value: minOffset, to: currentDate)!
            let entry = ServerStatusHSSnapshotEntry(date: entryDate, configuration: configuration, viewModel: vm)
            entries.append(entry)
        }
        
        for hourOffset in 1 ..< 11 { //360
            let timeStr = "\(hourOffset)hr ago"
            
            let vm = WidgetEntryViewModel(serverName: server.name, status: serverStatus, lastUpdated: timeStr, serverIcon: serverIcon, theme: widgetTheme)
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = ServerStatusHSSnapshotEntry(date: entryDate, configuration: configuration, viewModel: vm)
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .after(futureDate))
    }
}

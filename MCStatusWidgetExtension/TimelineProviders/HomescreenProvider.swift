//
//  HomescreenProvider.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 10/11/24.
//

import WidgetKit
import MCStatusDataLayer
import UIKit


struct HomescreenProvider: AppIntentTimelineProvider {
    // this view is for when the widget has been added the the homescreen, but the user has not selected a server
    func placeholder(in context: Context) -> ServerStatusHSSnapshotEntry {
        let vm = WidgetEntryViewModel()
        return ServerStatusHSSnapshotEntry(date: Date(), configuration: ServerSelectWidgetIntent(), viewModel: vm)
    }
    
    // is context.isPreview is true, this is the view to show when someone clicked add widget. Just show preview with placeholder data. if it is false, yo ushould actually load the current state of the view by getting the status
    func snapshot(for configuration: ServerSelectWidgetIntent, in context: Context) async -> ServerStatusHSSnapshotEntry {
        let vm = WidgetEntryViewModel()
        return ServerStatusHSSnapshotEntry(date: Date(), configuration: configuration, viewModel: vm)
    }
    
    
    func timeline(for configuration: ServerSelectWidgetIntent, in context: Context) async -> Timeline<ServerStatusHSSnapshotEntry> {
        var entries: [ServerStatusHSSnapshotEntry] = []
        
        // step 1 load server from DB
        let container = SwiftDataHelper.getModelContainter()
        guard let serverId = configuration.Server?.id,
              let uuid = UUID(uuidString: serverId),
              let server = await SwiftDataHelper.getSavedServerById(container: container, server_id: uuid) else {
            return Timeline(entries: entries, policy: .atEnd)
        }
       

        // step 2 load status
        let statusResult = await ServerStatusChecker.checkServer(server: server)
        let serverIcon = ImageHelper.convertFavIconString(favIcon: statusResult.favIcon) ?? UIImage(named: "DefaultIcon")!
        let theme = if let themeId = configuration.Theme?.id, let themeEnum = Theme(rawValue: themeId) {
            themeEnum
        } else {
            Theme.auto
        }
        
        
        let currentDate = Date()
        
        for minOffset in 0 ..< 60 {
            
            var timeStr = ""
            if (minOffset == 0) {
                timeStr = "now"
            } else {
                timeStr = "\(minOffset)m ago"
            }
            
            let vm = WidgetEntryViewModel(serverName: server.name, status: statusResult, lastUpdated: timeStr, serverIcon: serverIcon, theme: theme)
            let entryDate = Calendar.current.date(byAdding: .minute, value: minOffset, to: currentDate)!
            let entry = ServerStatusHSSnapshotEntry(date: entryDate, configuration: configuration, viewModel: vm)
            entries.append(entry)
        }
        
        for hourOffset in 1 ..< 11 { //360
            let timeStr = "\(hourOffset)hr ago"
            
            let vm = WidgetEntryViewModel(serverName: server.name, status: statusResult, lastUpdated: timeStr, serverIcon: serverIcon, theme: theme)
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = ServerStatusHSSnapshotEntry(date: entryDate, configuration: configuration, viewModel: vm)
            entries.append(entry)
        }
        
        let futureDate = Calendar.current.date(byAdding: .minute, value: 10, to: Date())!
        return Timeline(entries: entries, policy: .after(futureDate))
    }
}

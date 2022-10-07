//
//  WidgetProviders.swift
//  MinecraftServerStatusHSWidgetExtension
//
//  Created by Tomer Shemesh on 10/5/22.
//  Copyright © 2022 ShemeshApps. All rights reserved.
//

import Foundation
import WidgetKit
import UIKit


// actually fix this at some point lol
func getServerById(id: String) -> SavedServer? {
    let realm = initializeRealmDb()

    let servers = realm.objects(SavedServer.self).sorted(byKeyPath: "order")
    return servers.first { server in
        server.id == id
    }
}


func getWidgetVMFromServer(widgetServerOpt: ServerIntentType?) -> WidgetEntryViewModel {
    var vm = WidgetEntryViewModel()
    
    if  let widgetServer = widgetServerOpt, let identifier = widgetServer.identifier, let savedServer = getServerById(id: identifier) {
        vm.serverName = savedServer.name
        vm.setServerIcon(base64Data: savedServer.serverIcon)
    }
    
    return vm
}



func calculateTimeline(timelineFactory: TimelineProviderFactoryProtocol) {
    let currentDate = Date()
    let futureDate = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!

    guard let widgetServer = timelineFactory.getServer(), let identifier = widgetServer.identifier, let savedServer = getServerById(id: identifier), !timelineFactory.isPreview() else {
      
        let entryDate = Date()
        var vm = WidgetEntryViewModel()
        vm.serverName = "Edit Widget"
        vm.progressString = "-- / --"
        vm.lastUpdated = "now"
        vm.progressValue = 0
        vm.playersString = ""
        vm.isDefaultView = true
        
        timelineFactory.addTimelineEntry(entryDate: entryDate, vm: vm)
        timelineFactory.completeTimeline()
        return
    }
            
    StatusChecker(addressAndPort: savedServer.serverUrl, serverType: savedServer.serverType).getStatus { status in
        DispatchQueue.main.async {
            let serverIcon = ImageHelper.convertFavIconString(favIcon: status.favicon) ?? UIImage(named: "DefaultIcon")!

            if (timelineFactory.shouldGenerateFutureEntires()) {
                for minOffset in 0 ..< 60 {
                    
                    var timeStr = ""
                    if (minOffset == 0) {
                        timeStr = "now"
                    } else {
                        timeStr = "\(minOffset)m ago"
                    }
                    
                    let vm = WidgetEntryViewModel(serverName: savedServer.name, status: status, lastUpdated: timeStr, serverIcon: serverIcon, theme: timelineFactory.getTheme())
                    let entryDate = Calendar.current.date(byAdding: .minute, value: minOffset, to: currentDate)!
                    timelineFactory.addTimelineEntry(entryDate: entryDate, vm: vm)
                }
                
                for hourOffset in 1 ..< 11 { //360
                    
                    let timeStr = "\(hourOffset)hr ago"
                    
                    let vm = WidgetEntryViewModel(serverName: savedServer.name, status: status, lastUpdated: timeStr, serverIcon: serverIcon, theme: timelineFactory.getTheme())
                    let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                    timelineFactory.addTimelineEntry(entryDate: entryDate, vm: vm)
                }
            } else {
                let vm = WidgetEntryViewModel(serverName: savedServer.name, status: status, lastUpdated: "now", serverIcon: serverIcon, theme: timelineFactory.getTheme())
                timelineFactory.addTimelineEntry(entryDate: currentDate, vm: vm)
            }
            
            

            timelineFactory.completeTimeline()
        }
    }
}







struct HomescreenProvider: IntentTimelineProvider {
    
    func getSnapshot(for configuration: ServerSelectIntent, in context: Context, completion: @escaping (ServerStatusHSSnapshotEntry) -> ()) {
        
        let entry = ServerStatusHSSnapshotEntry(date: Date(), configuration: configuration, viewModel: getWidgetVMFromServer(widgetServerOpt: configuration.Server))
        completion(entry)
    }

    func getTimeline(for configuration: ServerSelectIntent, in context: Context, completion: @escaping (Timeline<ServerStatusHSSnapshotEntry>) -> ()) {
        let factory = HSWidgetTimelineProvider(context: context, configuration: configuration, refreshInterval: 10, completion: completion)
        calculateTimeline(timelineFactory: factory)
    }
    
    func placeholder(in context: Context) -> ServerStatusHSSnapshotEntry {
        ServerStatusHSSnapshotEntry(date: Date(), configuration: ServerSelectIntent(), viewModel: WidgetEntryViewModel())
    }
}






struct LockscreenProvider: IntentTimelineProvider {
    func getTimeline(for configuration: ServerSelectNoThemeIntent, in context: Context, completion: @escaping (Timeline<ServerStatusLSSnapshotEntry>) -> Void) {
        let factory = LSWidgetTimelineProvider(context: context, configuration: configuration, refreshInterval: 10, completion: completion)
        calculateTimeline(timelineFactory: factory)
    }
    
        
    func getSnapshot(for configuration: ServerSelectNoThemeIntent, in context: Context, completion: @escaping (ServerStatusLSSnapshotEntry) -> ()) {
        let entry = ServerStatusLSSnapshotEntry(date: Date(), configuration: configuration, viewModel: getWidgetVMFromServer(widgetServerOpt: configuration.Server))
        completion(entry)
    }


    
    func placeholder(in context: Context) -> ServerStatusLSSnapshotEntry {
        ServerStatusLSSnapshotEntry(date: Date(), configuration: ServerSelectNoThemeIntent(), viewModel: WidgetEntryViewModel())
    }
}

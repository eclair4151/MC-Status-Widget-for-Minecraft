//
//  MinecraftServerStatusHSWidget.swift
//  MinecraftServerStatusHSWidget
//
//  Created by Tomer on 1/24/21.
//  Copyright © 2021 ShemeshApps. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import RealmSwift

struct Provider: IntentTimelineProvider {
    
    // actually fix this at some point lol
    func getServerById(id: String) -> SavedServer? {
        let realm = initializeRealmDb()

        let servers = realm.objects(SavedServer.self).sorted(byKeyPath: "order")
        return servers.first { server in
            server.id == id
        }
    }
    
    func getSnapshot(for configuration: ServerSelectIntent, in context: Context, completion: @escaping (ServerStatusSnapshotEntry) -> ()) {
        var vm = WidgetEntryViewModel()
        
        if let widgetServer = configuration.Server, let identifier = widgetServer.identifier, let savedServer = getServerById(id: identifier) {
            vm.serverName = savedServer.name
            vm.setServerIcon(base64Data: savedServer.serverIcon)
        }
        
        let entry = ServerStatusSnapshotEntry(date: Date(), configuration: configuration, viewModel: vm)
        completion(entry)
    }

    func getTimeline(for configuration: ServerSelectIntent, in context: Context, completion: @escaping (Timeline<ServerStatusSnapshotEntry>) -> ()) {
        
        let currentDate = Date()
        let futureDate = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!
        var entries: [ServerStatusSnapshotEntry] = []

        guard let widgetServer = configuration.Server, let identifier = widgetServer.identifier, let savedServer = getServerById(id: identifier), !context.isPreview else {
          
            let entryDate = Date()
            var vm = WidgetEntryViewModel()
            vm.serverName = "Select a Server"
            vm.progressString = "-- / --"
            vm.lastUpdated = "now"
            vm.progressValue = 0
            vm.playersString = ""
            let entry = ServerStatusSnapshotEntry(date: entryDate, configuration: configuration, viewModel: vm)
            entries.append(entry)
            
            let timeline = Timeline(entries:entries, policy: .after(futureDate))
            completion(timeline)
            return
        }
        
        let theme = Theme(rawValue: configuration.Theme?.identifier ?? "Auto") ?? Theme.auto
        
        StatusChecker(addressAndPort: savedServer.serverUrl).getStatus { status in
            DispatchQueue.main.async {
                var entries: [ServerStatusSnapshotEntry] = []

                let serverIcon = ImageHelper.convertFavIconString(favIcon: status.favicon) ?? UIImage(named: "DefaultIcon")!
                // Generate a timeline consisting of five entries an hour apart, starting from the current date.
                // 720 minutes will give us a 6 hour buffer
                for minOffset in 0 ..< 360 {
                    
                    var timeStr = ""
                    if (minOffset == 0) {
                        timeStr = "now"
                    } else if (minOffset < 60) {
                        timeStr = "\(minOffset)m ago"
                    } else {
                        let hr = minOffset/60
                        timeStr = "\(hr)hr ago"
                    }
                    
                    
                    let vm = WidgetEntryViewModel(serverName: savedServer.name, status: status, lastUpdated: timeStr, serverIcon: serverIcon, theme: theme)
        
                    let entryDate = Calendar.current.date(byAdding: .minute, value: minOffset, to: currentDate)!
                    let entry = ServerStatusSnapshotEntry(date: entryDate, configuration: configuration, viewModel: vm)
                    entries.append(entry)
                }

                //requet refresh in 15 minutes
                let timeline = Timeline(entries: entries, policy: .after(futureDate))
                completion(timeline)
            }
        }
    }
    
    func placeholder(in context: Context) -> ServerStatusSnapshotEntry {
        ServerStatusSnapshotEntry(date: Date(), configuration: ServerSelectIntent(), viewModel: WidgetEntryViewModel())
    }
}


struct ServerStatusSnapshotEntry: TimelineEntry {
    let date: Date
    let configuration: ServerSelectIntent
    let viewModel: WidgetEntryViewModel
}



struct MinecraftServerStatusHSWidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            if #available(iOSApplicationExtension 16.0, *) {
                CircularAccessoryWidgetView(entry: entry)
            } else {
                Text("Not implemented")
            }
            
     
        @unknown default:
            Text("Not implemented")
        }
    }
}


@main
struct MinecraftServerStatusHSWidget: Widget {
    let kind: String = "MinecraftServerStatusHSWidget"

    private let supportedFamilies:[WidgetFamily] = {
           if #available(iOSApplicationExtension 16.0, *) {
               return [.systemSmall, .systemMedium, .accessoryCircular]
           } else {
               return [.systemSmall, .systemMedium]
           }
       }()
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ServerSelectIntent.self, provider: Provider()) { entry in
            MinecraftServerStatusHSWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MC Status Widget")
        .description("Widget to show the status of Minecraft Server")
        .supportedFamilies(supportedFamilies)
    }
}

struct MinecraftServerStatusHSWidget_Previews: PreviewProvider {
    static var previews: some View {
        MinecraftServerStatusHSWidgetEntryView(
            entry: ServerStatusSnapshotEntry(
                date: Date(),
                configuration: ServerSelectIntent(),
                viewModel: WidgetEntryViewModel()
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("SmallWidget")
        
        
        if #available(iOSApplicationExtension 16.0, *) {
            MinecraftServerStatusHSWidgetEntryView(
                entry: ServerStatusSnapshotEntry(
                    date: Date(),
                    configuration: ServerSelectIntent(),
                    viewModel: WidgetEntryViewModel()
                )
            )
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .previewDisplayName("Circular")
        }
    }
}

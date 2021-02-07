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
        
        if let widgetServer = configuration.Server, let identifier = widgetServer.identifier, let savedServer = getServerById(id: identifier), !context.isPreview {
            vm.serverName = savedServer.name
            vm.setServerIcon(base64Data: savedServer.serverIcon)
        }
        
        let entry = ServerStatusSnapshotEntry(date: Date(), configuration: configuration, viewModel: vm)
        completion(entry)
    }

    func getTimeline(for configuration: ServerSelectIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let currentDate = Date()
        let futureDate = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!
        var entries: [ServerStatusSnapshotEntry] = []

        guard let widgetServer = configuration.Server, let identifier = widgetServer.identifier, let savedServer = getServerById(id: identifier) else {
            let timeline = Timeline(entries: entries, policy: .after(futureDate))
            completion(timeline)
            return
        }
        
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        // 720 minutes will give us a 12 hour buffer
        for minOffset in 0 ..< 720 {
            
            var timeStr = ""
            if (minOffset == 0) {
                timeStr = "now"
            } else if (minOffset < 60) {
                timeStr = "\(minOffset)min ago"
            } else {
                let hr = minOffset/60
                timeStr = "\(hr)hr ago"
            }
            
            var vm = WidgetEntryViewModel()
            vm.serverName = savedServer.name
            vm.lastUpdated = timeStr
            
            
            let entryDate = Calendar.current.date(byAdding: .minute, value: minOffset, to: currentDate)!
            let entry = ServerStatusSnapshotEntry(date: entryDate, configuration: configuration, viewModel: vm)
            entries.append(entry)
        }

        //requet refresh in 15 minutes
        let timeline = Timeline(entries: entries, policy: .after(futureDate))
        completion(timeline)
        
        
//        StatusChecker(addressAndPort: savedServer.serverUrl).getStatus { status in
//            var entries: [ServerStatusSnapshotEntry] = []
//
//            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//            // 720 minutes will give us a 12 hour buffer
//            let currentDate = Date()
//            for minOffset in 0 ..< 720 {
//
//                let timeStr = minOffset == 0 ? "Now" : "\(minOffset)min ago"
//
//                let entryDate = Calendar.current.date(byAdding: .minute, value: minOffset, to: currentDate)!
//                let entry = ServerStatusSnapshotEntry(date: entryDate, configuration: configuration, viewModel:WidgetEntryViewModel(serverName: savedServer.name, status: status, lastUpdated: timeStr))
//                entries.append(entry)
//            }
//
//            let timeline = Timeline(entries: entries, policy: .atEnd)
//            completion(timeline)
//        }
        
        
    }
    
    func placeholder(in context: Context) -> ServerStatusSnapshotEntry {
        ServerStatusSnapshotEntry(date: Date(), configuration: ServerSelectIntent(), viewModel: WidgetEntryViewModel())
    }
}




struct ProgressView: View {
    var progress: CGFloat
    var bgColor = Color.black.opacity(0.2)
    var filledColor = Color.blue

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(bgColor)
                    .frame(width: width,
                           height: height)
                    .cornerRadius(height / 2.0)

                Rectangle()
                    .foregroundColor(filledColor)
                    .frame(width: width * self.progress,
                           height: height)
                    .cornerRadius(height / 2.0)
            }
        }
    }
}


struct ServerStatusSnapshotEntry: TimelineEntry {
    let date: Date
    let configuration: ServerSelectIntent
    let viewModel: WidgetEntryViewModel
}



struct MinecraftServerStatusHSWidgetEntryView : View {
    var entry: Provider.Entry
    static let formatter = RelativeDateTimeFormatter()
    

    var body: some View {
        
        ZStack {
            Color("WidgetBackground")
            VStack {
                HStack {
                    Image(uiImage: entry.viewModel.icon).resizable()                .scaledToFit().frame(width: 32.0, height: 32.0)
                    Image(systemName: entry.viewModel.statusIcon).font(.system(size: 32)).foregroundColor(Color(entry.viewModel.statusColor))
                    Text(entry.viewModel.lastUpdated).bold()
                }.frame(height:32).padding(.top,25).padding(.bottom,6)
                Text(entry.viewModel.serverName).fontWeight(.bold).frame(height:32).padding(.leading, 6).padding(.trailing, 6)
                Spacer()
                HStack {
                    Text(entry.viewModel.progressString)
                    ProgressView(progress: CGFloat(entry.viewModel.progressValue)).frame(height:10)
                }.padding(EdgeInsets(top: 0, leading: 8, bottom: 40, trailing: 8)).frame(height:32)
               
            }
        }
        
    }
}


@main
struct MinecraftServerStatusHSWidget: Widget {
    let kind: String = "MinecraftServerStatusHSWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ServerSelectIntent.self, provider: Provider()) { entry in
            MinecraftServerStatusHSWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MC Status Widget")
        .description("Widget to show the status of Minecraft Server")
    }
}

struct MinecraftServerStatusHSWidget_Previews: PreviewProvider {
    static var previews: some View {
        MinecraftServerStatusHSWidgetEntryView(entry: ServerStatusSnapshotEntry(date: Date(), configuration: ServerSelectIntent(), viewModel: WidgetEntryViewModel()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

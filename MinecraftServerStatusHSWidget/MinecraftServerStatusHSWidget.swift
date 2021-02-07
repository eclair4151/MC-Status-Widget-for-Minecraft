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
    
    
    let realm: Realm

    init() {
        let sharedDirectory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.shemeshapps.MinecraftServerStatus")! as URL
        let sharedRealmURL = sharedDirectory.appendingPathComponent("db.realm")
        Realm.Configuration.defaultConfiguration = Realm.Configuration(fileURL: sharedRealmURL)
        
        self.realm = try! Realm()
    }
    
    func getServerById(id: String) -> SavedServer? {
        let servers = self.realm.objects(SavedServer.self).sorted(byKeyPath: "order")
        return servers.first { server in
            server.id == id
        }
    }
    
    func getSnapshot(for configuration: ServerSelectIntent, in context: Context, completion: @escaping (ServerStatusSnapshotEntry) -> ()) {
        let entry = ServerStatusSnapshotEntry(date: Date(), configuration: configuration, viewModel: WidgetEntryViewModel())
        
        completion(entry)
    }

    func getTimeline(for configuration: ServerSelectIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        guard let widgetServer = configuration.Server, let identifier = widgetServer.identifier, let savedServer = getServerById(id: identifier) else {
            return
        }
        
        
        StatusChecker(addressAndPort: savedServer.serverUrl).getStatus { status in
            var entries: [ServerStatusSnapshotEntry] = []
            
            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
            // 720 minutes will give us a 12 hour buffer
            let currentDate = Date()
            for minOffset in 0 ..< 720 {
                
                let timeStr = minOffset == 0 ? "Now" : "\(minOffset)min ago"
                
                let entryDate = Calendar.current.date(byAdding: .minute, value: minOffset, to: currentDate)!
                let entry = ServerStatusSnapshotEntry(date: entryDate, configuration: configuration, viewModel:WidgetEntryViewModel(serverName: savedServer.name, status: status, lastUpdated: timeStr))
                entries.append(entry)
            }

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
        
        
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

//struct ProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgressView(progress: 12)
//    }
//}







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


//struct ContentView: View {
//    static let formatter = RelativeDateTimeFormatter()
//
//    var body: some View {
//        let unixEpoch = Date(timeIntervalSince1970: 0)
//        return VStack {
//            Text("Current date is:")
//            Text("\(unixEpoch, formatter: Self.formatter)").bold()
//            Text("since the unix Epoch")
//            Spacer()
//        }
//    }
//}

@main
struct MinecraftServerStatusHSWidget: Widget {
    let kind: String = "MinecraftServerStatusHSWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ServerSelectIntent.self, provider: Provider()) { entry in
            MinecraftServerStatusHSWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct MinecraftServerStatusHSWidget_Previews: PreviewProvider {
    static var previews: some View {
        MinecraftServerStatusHSWidgetEntryView(entry: ServerStatusSnapshotEntry(date: Date(), configuration: ServerSelectIntent(), viewModel: WidgetEntryViewModel()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

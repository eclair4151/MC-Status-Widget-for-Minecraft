//
//  MCStatusWidgetExtension.swift
//  MCStatusWidgetExtension
//
//  Created by Tomer Shemesh on 10/9/24.
//

import WidgetKit
import SwiftUI
import MCStatusDataLayer



struct MinecraftServerStatusHSWidget: Widget {
    let kind: String = "MinecraftServerStatusHSWidget"

    private let supportedFamilies:[WidgetFamily] = {
            return [.systemSmall, .systemMedium]
       }()
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ServerSelectWidgetIntent.self, provider: HomescreenProvider()) { entry in
            MinecraftServerStatusHSWidgetEntryView(entry: entry).containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("MC Status Widget")
        .description("Widget to show the status of Minecraft Server")
        .contentMarginsDisabled()
        .supportedFamilies(supportedFamilies)
    }
}


struct MinecraftServerStatusHSWidgetEntryView : View {
    var entry: HomescreenProvider.Entry
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
     
        @unknown default:
            Text("Not implemented")
        }
    }
}



struct HomescreenProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> ServerStatusHSSnapshotEntry {
        let vm = WidgetEntryViewModel()
        return ServerStatusHSSnapshotEntry(date: Date(), configuration: ServerSelectWidgetIntent(), viewModel: vm)
    }
    
    func snapshot(for configuration: ServerSelectWidgetIntent, in context: Context) async -> ServerStatusHSSnapshotEntry {
        let vm = WidgetEntryViewModel()
        return ServerStatusHSSnapshotEntry(date: Date(), configuration: configuration, viewModel: vm)
    }
    
    
    func timeline(for configuration: ServerSelectWidgetIntent, in context: Context) async -> Timeline<ServerStatusHSSnapshotEntry> {
        var entries: [ServerStatusHSSnapshotEntry] = []

        let vm = WidgetEntryViewModel()
        let currentDate = Date()
        let entryDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let entry = ServerStatusHSSnapshotEntry(date: currentDate, configuration: configuration, viewModel: vm)
        entries.append(entry)
        return Timeline(entries: entries, policy: .atEnd)
    }
}







struct ServerStatusHSSnapshotEntry: TimelineEntry {
    let date: Date
    let configuration: ServerSelectWidgetIntent
    let viewModel: WidgetEntryViewModel
}


//extension ConfigurationAppIntent {
//    fileprivate static var smiley: ConfigurationAppIntent {
//        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "😀"
//        return intent
//    }
//    
//    fileprivate static var starEyes: ConfigurationAppIntent {
//        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "🤩"
//        return intent
//    }
//}
//
//#Preview(as: .systemSmall) {
//    MCStatusWidgetExtension()
//} timeline: {
//    SimpleEntry(date: .now, configuration: .smiley)
//    SimpleEntry(date: .now, configuration: .starEyes)
//}

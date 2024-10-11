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
            MinecraftServerStatusHSWidgetEntryView(entry: entry)
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


struct ServerStatusHSSnapshotEntry: TimelineEntry {
    let date: Date
    let configuration: ServerSelectWidgetIntent
    let viewModel: WidgetEntryViewModel
}


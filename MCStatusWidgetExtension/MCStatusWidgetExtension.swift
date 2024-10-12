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
            
            MinecraftServerStatusHSWidgetEntryView(entry: entry).containerBackground(for: .widget) {
                entry.viewModel.bgColor
            }
        }
        .configurationDisplayName("MC Status Widget")
        .description("Widget to show the status of Minecraft Server")
        .contentMarginsDisabled()
        .supportedFamilies(supportedFamilies)
    }
}



struct MinecraftServerStatusLSWidget1: Widget {
    let kind: String = "MinecraftServerStatusLSWidget1"

    private let supportedFamilies:[WidgetFamily] = {
        
        #if targetEnvironment(macCatalyst)
            return []
        #else
            return [.accessoryCircular, .accessoryRectangular]
        #endif
          
       }()
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ServerSelectNoThemeWidgetIntent.self, provider: LockscreenProvider()) { entry in
            MinecraftServerStatusLSWidgetEntryView(entry: entry, widgetType: .ImageAndText).containerBackground(for: .widget) {}
        }
        .configurationDisplayName("Lockscreen Widget 1")
        .description("Widget to show the status of Minecraft Server")
        .supportedFamilies(supportedFamilies)
    }
}



struct MinecraftServerStatusLSWidget2: Widget {
    let kind: String = "MinecraftServerStatusLSWidget2"

    private let supportedFamilies:[WidgetFamily] = {
        #if targetEnvironment(macCatalyst)
            return []
        #else
            return [.accessoryCircular]
        #endif
       }()
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ServerSelectNoThemeWidgetIntent.self, provider: LockscreenProvider()) { entry in
            MinecraftServerStatusLSWidgetEntryView(entry: entry, widgetType: .OnlyImage).containerBackground(for: .widget) {}
        }
        .configurationDisplayName("Lockscreen Widget 2")
        .description("Widget to show the status of Minecraft Server")
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
        case .systemMedium:
            MediumWidgetView(entry: entry)
            
        @unknown default:
            Text("Not implemented")
        }
    }
}


enum LSWidgetType {
    case ImageAndText
    case OnlyImage
}

struct MinecraftServerStatusLSWidgetEntryView : View {
    var entry: LockscreenProvider.Entry
    var widgetType: LSWidgetType = .ImageAndText //defult
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
    #if !targetEnvironment(macCatalyst)

        case .accessoryCircular:
            switch widgetType {
                case .ImageAndText:
                    CircularAccessoryWidgetView1(entry: entry)
                case .OnlyImage:
                    CircularAccessoryWidgetView2(entry: entry)
            }
        case .accessoryRectangular:
            RectangularAccessoryWidgetView(entry: entry)
    #endif
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

struct ServerStatusLSSnapshotEntry: TimelineEntry {
    let date: Date
    let configuration: ServerSelectNoThemeWidgetIntent
    let viewModel: WidgetEntryViewModel
}

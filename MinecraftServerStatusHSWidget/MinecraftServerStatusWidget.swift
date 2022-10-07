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



struct ServerStatusHSSnapshotEntry: TimelineEntry {
    let date: Date
    let configuration: ServerSelectIntent
    let viewModel: WidgetEntryViewModel
}

struct ServerStatusLSSnapshotEntry: TimelineEntry {
    let date: Date
    let configuration: ServerSelectNoThemeIntent
    let viewModel: WidgetEntryViewModel
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




@main
struct MinecraftWidgetBundle: WidgetBundle {
   var body: some Widget {
       MinecraftServerStatusHSWidget()
       MinecraftServerStatusLSWidget1()
       MinecraftServerStatusLSWidget2()

   }
}


struct MinecraftServerStatusLSWidget1: Widget {
    let kind: String = "MinecraftServerStatusLSWidget1"

    private let supportedFamilies:[WidgetFamily] = {
        
        #if targetEnvironment(macCatalyst)
            return []
        #else
        if #available(iOSApplicationExtension 16.0, *) {
            return [.accessoryCircular, .accessoryRectangular]
        } else {
            return []
        }
        #endif
          
       }()
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ServerSelectNoThemeIntent.self, provider: LockscreenProvider()) { entry in
            MinecraftServerStatusLSWidgetEntryView(entry: entry, widgetType: .ImageAndText)
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
        if #available(iOSApplicationExtension 16.0, *) {
            return [.accessoryCircular]
        } else {
            return []
        }
        #endif
       }()
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ServerSelectNoThemeIntent.self, provider: LockscreenProvider()) { entry in
            MinecraftServerStatusLSWidgetEntryView(entry: entry, widgetType: .OnlyImage)
        }
        .configurationDisplayName("Lockscreen Widget 2")
        .description("Widget to show the status of Minecraft Server")
        .supportedFamilies(supportedFamilies)
    }
}


struct MinecraftServerStatusHSWidget: Widget {
    let kind: String = "MinecraftServerStatusHSWidget"

    private let supportedFamilies:[WidgetFamily] = {
            return [.systemSmall, .systemMedium]
       }()
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ServerSelectIntent.self, provider: HomescreenProvider()) { entry in
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
            entry: ServerStatusHSSnapshotEntry(
                date: Date(),
                configuration: ServerSelectIntent(),
                viewModel: WidgetEntryViewModel()
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("SmallWidget")
        
        #if !targetEnvironment(macCatalyst)
        if #available(iOSApplicationExtension 16.0, *) {
            MinecraftServerStatusLSWidgetEntryView(
                entry: ServerStatusLSSnapshotEntry(
                    date: Date(),
                    configuration: ServerSelectNoThemeIntent(),
                    viewModel: WidgetEntryViewModel()
                )
            )
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .previewDisplayName("Circular")
            
            MinecraftServerStatusLSWidgetEntryView(
                entry: ServerStatusLSSnapshotEntry(
                    date: Date(),
                    configuration: ServerSelectNoThemeIntent(),
                    viewModel: WidgetEntryViewModel()
                )
            )
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("Rectangle")
        }
        #endif

    }
}











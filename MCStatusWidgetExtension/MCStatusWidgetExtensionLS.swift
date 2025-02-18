import SwiftUI
import WidgetKit
import MCStatusDataLayer

struct MinecraftServerStatusLSWidget1: Widget {
    private let kind = "MinecraftServerStatusLSWidget1"
    
    private let supportedFamilies: [WidgetFamily] = {
#if targetEnvironment(macCatalyst)
        []
#elseif os(watchOS)
        [.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner]
#else
        [.accessoryCircular, .accessoryRectangular, .accessoryInline]
#endif
    }()
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ServerSelectNoThemeWidgetIntent.self,
            provider: LockscreenProvider(widgetType: .ImageAndText)
        ) { entry in
            MinecraftServerStatusLSWidgetEntryView(
                entry: entry,
                widgetType: .ImageAndText
            )
            .containerBackground(for: .widget) {}
            .widgetURL(URL(string: entry.configuration.Server?.id ?? ""))
        }
        .configurationDisplayName("Lockscreen Widget 1")
        .description("Widget to show the status of Minecraft Server")
        .supportedFamilies(supportedFamilies)
    }
}

struct MinecraftServerStatusLSWidget2: Widget {
    private let kind = "MinecraftServerStatusLSWidget2"
    
    private let supportedFamilies: [WidgetFamily] = {
#if targetEnvironment(macCatalyst)
        []
#elseif os(watchOS)
        [.accessoryCircular]
#else
        [.accessoryCircular, .accessoryInline]
#endif
    }()
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ServerSelectNoThemeWidgetIntent.self,
            provider: LockscreenProvider(widgetType: .OnlyImage)
        ) { entry in
            MinecraftServerStatusLSWidgetEntryView(
                entry: entry,
                widgetType: .OnlyImage)
            .containerBackground(for: .widget) {}
        }
        .configurationDisplayName("Lockscreen Widget 2")
        .description("Widget to show the status of Minecraft Server")
        .supportedFamilies(supportedFamilies)
    }
}

enum LSWidgetType {
    case ImageAndText, OnlyImage
}

struct MinecraftServerStatusLSWidgetEntryView: View {
    var entry: LockscreenProvider.Entry
    var widgetType: LSWidgetType = .ImageAndText //defult
    
    @Environment(\.widgetFamily) private var family
    
    @ViewBuilder
    var body: some View {
        switch family {
#if !targetEnvironment(macCatalyst)
        case .accessoryCircular:
            switch widgetType {
            case .ImageAndText:
                CircularAccessoryWidgetView1(entry)
                
            case .OnlyImage:
                CircularAccessoryWidgetView2(entry)
            }
            
        case .accessoryRectangular:
            RectangularAccessoryWidgetView(entry)
            
        case .accessoryInline:
            switch widgetType {
            case .ImageAndText:
                InlineAccessoryWidgetView(entry)
                
            case .OnlyImage:
                InlineAccessoryWidgetView2(entry)
            }
            
        case .accessoryCorner:
            CornerAccessoryWidgetView1(entry)
#endif
        @unknown default:
            Text("Not implemented")
        }
    }
}

struct ServerStatusLSSnapshotEntry: TimelineEntry {
    let date: Date
    let configuration: ServerSelectNoThemeWidgetIntent
    let vm: WidgetEntryVM
}

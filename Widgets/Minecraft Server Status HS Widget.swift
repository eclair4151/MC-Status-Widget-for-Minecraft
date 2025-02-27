import SwiftUI
import WidgetKit
import MCStatsDataLayer

struct MinecraftServerStatusHSWidget: Widget {
    private let kind = "MinecraftServerStatusHSWidget"
    
    private let supportedFamilies: [WidgetFamily] = [
        .systemSmall, .systemMedium
    ]
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectServerIntent.self,
            provider: HomescreenProvider()
        ) { entry in
            MinecraftServerStatusHSWidgetEntryView(entry)
                .containerBackground(for: .widget) {
                    if entry.configuration.Theme == nil || entry.configuration.Theme?.id ?? "" == Theme.auto.rawValue {
                        entry.vm.bgColor
                    } else {
                        entry.vm.bgColor
                            .environment(
                                \.colorScheme,
                                 (entry.configuration.Theme?.id ?? "" == Theme.dark.rawValue)
                                 ? .dark : .light
                            )
                    }
                }
                .widgetURL(URL(string: entry.configuration.Server?.id ?? ""))
        }
        .configurationDisplayName("MC Stats Widget")
        .description("Widget to show the status of Minecraft Server")
        .contentMarginsDisabled()
        .supportedFamilies(supportedFamilies)
    }
}

struct MinecraftServerStatusHSWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    
    private var entry: HomescreenProvider.Entry
    
    init(_ entry: HomescreenProvider.Entry) {
        self.entry = entry
    }
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry)
            
        case .systemMedium:
            MediumWidgetView(entry)
            
        default:
            Text("Not implemented")
        }
    }
}

struct ServerStatusHSSnapshotEntry: TimelineEntry {
    let date: Date
    let configuration: SelectServerIntent
    let vm: WidgetEntryVM
}

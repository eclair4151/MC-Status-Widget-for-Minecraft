import Foundation
import SwiftUI
import Intents
import WidgetKit

struct CircularAccessoryWidgetView1: View {
    private var entry: LockscreenProvider.Entry
    
    init(_ entry: LockscreenProvider.Entry) {
        self.entry = entry
    }
    
    private var iconSize: CGFloat {
#if os(watchOS)
        15
#else
        18
#endif
    }
    
    private var iconTopPadding: CGFloat {
#if os(watchOS)
        4
#else
        0
#endif
    }
    
    var body: some View {
#if !targetEnvironment(macCatalyst)
        Gauge(value: entry.vm.progressValue) {
            VStack(spacing: 1) {
                ZStack {
                    // Adjust spacing as needed
                    HStack(spacing: 4) {
                        if let statusIcon = entry.vm.statusIcon {
                            Image(systemName: statusIcon)
                                .fontSize(iconSize)
                                .padding(2)
                                .widgetAccentable()
                            
                        } else if entry.vm.viewType == .Unconfigured {
#if os(watchOS)
                            Text("...")
                                .padding(2)
                                .multilineTextAlignment(.center)
#else
                            Text("Edit Widget")
                                .padding(2)
                                .multilineTextAlignment(.center)
#endif
                        } else {
                            if #available(iOSApplicationExtension 18, watchOS 11, *) {
                                Image(uiImage: entry.vm.icon)
                                    .resizable()
                                    .widgetAccentedRenderingMode(.accentedDesaturated)
                                    .scaledToFit()
                                    .frame(width: iconSize, height: iconSize)
                                    .padding(0)
                                    .padding(.top, iconTopPadding)
                                    .widgetAccentable()
                                
                            } else {
                                Image(uiImage: entry.vm.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: iconSize, height: iconSize)
                                    .padding(0)
                                    .padding(.top, iconTopPadding)
                                    .widgetAccentable()
                            }
                        }
                    }
                    
                    Button(intent: RefreshWidgetIntent()) {
                        Color.clear
                    }
                    .buttonStyle(.plain)
                }
                
                VStack {
                    Text(entry.vm.playersOnline)
                    
                    if entry.configuration.showMaxPlayerCount {
                        Text("/ \(entry.vm.playersMax.description)")
                    }
                }
                .padding(.bottom, 4)
                .padding(.horizontal,2)
                .minimumScaleFactor(0.01)
                .semibold()
            }
        }
        .gaugeStyle(.accessoryCircularCapacity)
#endif
    }
}

#if !targetEnvironment(macCatalyst)
struct MinecraftServerStatusHSWidget_CircularPreview: PreviewProvider {
    static var previews: some View {
        MinecraftServerStatusLSWidgetEntryView(
            entry: ServerStatusLSSnapshotEntry(
                date: Date(),
                configuration: ServerSelectNoThemeWidgetIntent(),
                vm: WidgetEntryVM()
            )
        )
        .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
#endif

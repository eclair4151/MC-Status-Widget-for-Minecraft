import SwiftUI
import Intents
import WidgetKit

struct RectangularAccessoryWidgetView: View {
    private var entry: LockscreenProvider.Entry
    
    init(_ entry: LockscreenProvider.Entry) {
        self.entry = entry
    }
    
    let iconSize = 16.0
    
    var body: some View {
#if !targetEnvironment(macCatalyst)
        Gauge (value: entry.vm.progressValue) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 0) {
                    if let statusIcon = entry.vm.statusIcon {
                        Image(systemName: statusIcon)
                            .fontSize(20)
                            .padding(2)
                            .widgetAccentable()
                    } else {
                        if #available(iOSApplicationExtension 18, watchOS 11, *) {
                            Image(uiImage: entry.vm.icon)
                                .resizable()
                                .widgetAccentedRenderingMode(.accentedDesaturated)
                                .scaledToFit()
                                .frame(width: iconSize, height: iconSize)
                                .padding(0)
                                .widgetAccentable()
                        } else {
                            Image(uiImage: entry.vm.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconSize, height: iconSize)
                                .padding(0)
                                .widgetAccentable()
                        }
                    }
                    
                    Text(entry.vm.serverName)
                        .headline()
                        .padding(.leading, 5)
                    
                    Spacer()
                    
                    Button(intent: RefreshWidgetIntent()) {
                        HStack(spacing: 4) { // Adjust spacing as needed
                            Image(systemName: "arrow.clockwise")
                                .imageScale(.medium)
                                .frame(width: 5, height: 5)
                                .scaleEffect(CGSize(width: 0.70, height: 0.70), anchor: .center)
                                .foregroundColor(.veryTransparentText) // You can adjust the size as needed
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                Text(entry.vm.progressString)
            }
        }
        .gaugeStyle(.accessoryLinearCapacity)
#endif
    }
}

#if !targetEnvironment(macCatalyst)
struct MinecraftServerStatusHSWidget_RectanglePreview: PreviewProvider {
    static var previews: some View {
        MinecraftServerStatusLSWidgetEntryView(entry: ServerStatusLSSnapshotEntry(date: Date(), configuration: ServerSelectNoThemeWidgetIntent(), vm: WidgetEntryVM()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
#endif

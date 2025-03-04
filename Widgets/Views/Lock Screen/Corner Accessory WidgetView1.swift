import SwiftUI
import Intents
import WidgetKit

struct CornerAccessoryWidgetView1: View {
    private var entry: LockscreenProvider.Entry
    
    init(_ entry: LockscreenProvider.Entry) {
        self.entry = entry
    }
    
    var iconSize = 27.0
    
    var body: some View {
#if !os(macOS)
        ZStack {
            if let statusIcon = entry.vm.statusIcon {
                Image(systemName: statusIcon)
                    .fontSize(iconSize)
                    .widgetAccentable()
                
            } else if entry.vm.viewType == .Unconfigured {
                Text("...")
                
            } else {
                if #available(iOSApplicationExtension 18, watchOS 11, *) {
                    Image(uiImage: entry.vm.icon)
                        .resizable()
                        .widgetAccentedRenderingMode(.accentedDesaturated)
                        .scaledToFit().frame(width: iconSize, height: iconSize).padding(0)
                        .widgetAccentable()
                    
                } else {
                    Image(uiImage: entry.vm.icon)
                        .resizable()
                        .scaledToFit().frame(width: iconSize, height: iconSize).padding(0)
                        .widgetAccentable()
                }
            }
            
            Button(intent: RefreshWidgetIntent()) {
                Color.clear
            }
            .buttonStyle(.plain)
        }
        .padding(0)
        .widgetLabel {
            Gauge(value: entry.vm.progressValue) {
                Text("")
            } currentValueLabel: {
                Text("")
            } minimumValueLabel: {
                // Watch out for clipping)
                Text(String(entry.vm.playersOnline))
            } maximumValueLabel: {
                // Watch out for clipping
                Text(String(entry.vm.playersMax))
            }
            .tint(Color(hex: "#2159ad"))
            .gaugeStyle(.accessoryLinearCapacity).widgetAccentable()
        }
#endif
    }
}

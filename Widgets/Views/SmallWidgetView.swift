import SwiftUI
import Intents
import WidgetKit

struct BaseWidgetView: View {
    private var entry: HomescreenProvider.Entry
    
    init(_ entry: HomescreenProvider.Entry) {
        self.entry = entry
    }
    
    @Environment(\.widgetRenderingMode) private var widgetRenderingMode
    
    private var progressBgOpacity: Double {
        if widgetRenderingMode == .accented {
            0.6
        } else {
            1
        }
    }
    
    private var progressBgColor: Color {
        if widgetRenderingMode == .accented {
            .primary
        } else {
            .gray
        }
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .trailing, spacing: 0) {
                Text(entry.vm.serverName)
                    .semibold()
                    .foregroundColor(.semiTransparentText)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .lineLimit(1)
                    .fontSize(16)
                    .widgetAccentable()
                
                Button(intent: RefreshWidgetIntent()) {
                    // Adjust spacing as needed
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.clockwise")
                            .imageScale(.medium)
                            .frame(width: 16, height: 16)
                            .scaleEffect(CGSize(width: 0.65, height: 0.65), anchor: .center)
                            .foregroundColor(.veryTransparentText)
                            .invalidatableContent() // You can adjust the size as needed
                        
                        Text(entry.vm.lastUpdated)
                            .fontSize(14)
                            .lineLimit(1)
                            .foregroundColor(.veryTransparentText) // This is your variable text
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                ZStack {
                    // hack for allowing widgetAccentedRenderingMode
                    if #available(iOSApplicationExtension 18, *) {
                        Image(uiImage: entry.vm.icon)
                            .resizable()
                            .widgetAccentedRenderingMode(WidgetAccentedRenderingMode.accentedDesaturated)
                            .scaledToFit().frame(width: 36, height: 36, alignment: .leading)
                            .widgetAccentable()
                    } else {
                        Image(uiImage: entry.vm.icon)
                            .resizable()
                            .scaledToFit().frame(width: 36, height: 36, alignment: .leading)
                    }
                    
                    if let statusIcon = entry.vm.statusIcon, !statusIcon.isEmpty {
                        if widgetRenderingMode == .accented {
                            Image(systemName: statusIcon)
                                .fontSize(24)
                                .offset(x: 18)
                                .widgetAccentable()
                        } else {
                            Image(systemName: statusIcon)
                                .fontSize(24)
                                .foregroundColor(Color.unknownColor)
                                .background {
                                    Color.white
                                        .mask(Circle())
                                        .padding(4)
                                }
                                .offset(x: 18)
                                .widgetAccentable()
                        }
                    }
                }
                
                Text(entry.vm.progressString)
                    .bold()
                    .fontSize(CGFloat(entry.vm.progressStringSize))
                    .foregroundColor(.regularText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top,3)
                    .padding(.trailing, 16)
                    .opacity(entry.vm.progressStringAlpha)
                
                if entry.vm.statusIcon == nil {
                    CustomProgressView(
                        progress: CGFloat(entry.vm.progressValue),
                        bgColor: self.progressBgColor,
                        bgOpacity: self.progressBgOpacity
                    )
                    .frame(height: 6)
                    .padding(.top, 6)
                }
            }
        }
    }
}

struct SmallWidgetView: View {
    private var entry: HomescreenProvider.Entry
    
    init(_ entry: HomescreenProvider.Entry) {
        self.entry = entry
    }
    
    var body: some View {
        if entry.configuration.Theme == nil || entry.configuration.Theme?.id ?? "" == Theme.auto.rawValue {
            BaseWidgetView(entry)
                .padding()
                .padding(.bottom, 3)
        } else {
            BaseWidgetView(entry)
                .padding()
                .padding(.bottom, 3)
                .environment(
                    \.colorScheme,
                     (entry.configuration.Theme?.id ?? "" == Theme.dark.rawValue)
                     ? .dark : .light
                )
        }
    }
}

struct MinecraftServerStatusHSWidget_SmallPreview: PreviewProvider {
    static var previews: some View {
        MinecraftServerStatusHSWidgetEntryView(
            ServerStatusHSSnapshotEntry(
                date: Date(),
                configuration: ServerSelectWidgetIntent(),
                vm: WidgetEntryVM()
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

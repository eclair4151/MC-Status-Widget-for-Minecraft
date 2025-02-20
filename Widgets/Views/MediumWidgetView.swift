import SwiftUI
import Intents
import WidgetKit

struct MediumWidgetView: View {
    private var entry: HomescreenProvider.Entry
    
    init(_ entry: HomescreenProvider.Entry) {
        self.entry = entry
    }
    
    var body: some View {
        if entry.configuration.Theme == nil || entry.configuration.Theme?.id ?? "" == Theme.auto.rawValue {
            InnerMediumWidget(entry)
        } else {
            InnerMediumWidget(entry)
                .environment(
                    \.colorScheme,
                     (entry.configuration.Theme?.id ?? "" == Theme.dark.rawValue)
                     ? .dark : .light
                )
        }
    }
}

private struct InnerMediumWidget: View {
    private var entry: HomescreenProvider.Entry
    
    init(_ entry: HomescreenProvider.Entry) {
        self.entry = entry
    }
    
    var body: some View {
        VStack {
            BaseWidgetView(entry)
            
            Text(entry.vm.progressString)
                .fontWeight(.regular)
                .foregroundColor(.veryTransparentText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .fontSize(13)
        }
        .padding()
    }
}

struct MinecraftServerStatusHSWidget_MediumPreview: PreviewProvider {
    static var previews: some View {
        MinecraftServerStatusHSWidgetEntryView(
            ServerStatusHSSnapshotEntry(
                date: Date(),
                configuration: SelectServerIntent(),
                vm: WidgetEntryVM()
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

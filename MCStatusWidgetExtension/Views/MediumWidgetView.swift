import SwiftUI
import Intents
import WidgetKit

struct MediumWidgetView : View {
    var entry: HomescreenProvider.Entry
    
    var body: some View {
        if entry.configuration.Theme == nil || entry.configuration.Theme?.id ?? "" == Theme.auto.rawValue {
            InnerMediumWidget(entry: entry)
        } else {
            InnerMediumWidget(entry: entry)
                .environment(
                    \.colorScheme,
                     (entry.configuration.Theme?.id ?? "" == Theme.dark.rawValue)
                     ? .dark : .light
                )
        }
    }
}

private struct InnerMediumWidget : View {
    var entry: HomescreenProvider.Entry
    
    var body: some View {
        VStack {
            BaseWidgetView(entry: entry)
            Text(entry.vm.playersString)
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
        MinecraftServerStatusHSWidgetEntryView(entry: ServerStatusHSSnapshotEntry(date: Date(), configuration: ServerSelectWidgetIntent(), vm: WidgetEntryVM()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

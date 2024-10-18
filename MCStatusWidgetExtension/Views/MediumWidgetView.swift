//
//  MediumWidgetView.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 10/11/24.
//


//
//  MediumWidgetView.swift
//  MinecraftServerStatusHSWidgetExtension
//
//  Created by Tomer on 2/7/21.
//  Copyright © 2021 ShemeshApps. All rights reserved.
//

import Foundation
import SwiftUI
import Intents
import WidgetKit

struct MediumWidgetView : View {
    var entry: HomescreenProvider.Entry

    var body: some View {
        if(entry.configuration.Theme == nil || entry.configuration.Theme?.id ?? "" == Theme.auto.rawValue) {
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
            Text(entry.viewModel.playersString)
                .fontWeight(.regular)
                .foregroundColor(.veryTransparentText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .font(.system(size: 13))
        }.padding()
    }
}


struct MinecraftServerStatusHSWidget_MediumPreview: PreviewProvider {
    static var previews: some View {
        MinecraftServerStatusHSWidgetEntryView(entry: ServerStatusHSSnapshotEntry(date: Date(), configuration: ServerSelectWidgetIntent(), viewModel: WidgetEntryViewModel()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

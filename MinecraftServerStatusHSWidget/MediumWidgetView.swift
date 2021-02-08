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
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color("WidgetBackground")
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
}


struct MinecraftServerStatusHSWidget_MediumPreview: PreviewProvider {
    static var previews: some View {
        MinecraftServerStatusHSWidgetEntryView(entry: ServerStatusSnapshotEntry(date: Date(), configuration: ServerSelectIntent(), viewModel: WidgetEntryViewModel()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

//
//  SmallWidgetView.swift
//  MinecraftServerStatusHSWidgetExtension
//
//  Created by Tomer on 2/7/21.
//  Copyright © 2021 ShemeshApps. All rights reserved.
//

import Foundation
import SwiftUI
import Intents
import WidgetKit




struct BaseWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.viewModel.serverName)
                    .fontWeight(.medium)
                    .foregroundColor(.semiTransparentText)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .lineLimit(1)
                    .font(.system(size: 16))
                Text(entry.viewModel.lastUpdated)
                    .fontWeight(.regular)
                    .foregroundColor(.veryTransparentText)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .lineLimit(1)
                    .font(.system(size: 16))
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Image(uiImage: entry.viewModel.icon).resizable()
                    .scaledToFit().frame(width: 36.0, height: 36.0)
                Text(entry.viewModel.progressString)
                    .fontWeight(.bold)
                    .font(.system(size: 23))
                    .foregroundColor(.regularText)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top,3)
                ProgressView(progress: CGFloat(entry.viewModel.progressValue))
                    .frame(height:6)
                    .padding(.top,6)
            }
        }
    }
}


struct SmallWidgetView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color("WidgetBackground")
            BaseWidgetView(entry: entry).padding().padding(.bottom,3)
        }
    }
}


struct MinecraftServerStatusHSWidget_SmallPreview: PreviewProvider {
    static var previews: some View {
        MinecraftServerStatusHSWidgetEntryView(entry: ServerStatusSnapshotEntry(date: Date(), configuration: ServerSelectIntent(), viewModel: WidgetEntryViewModel()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

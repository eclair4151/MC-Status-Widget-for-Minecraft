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
    var entry: HomescreenProvider.Entry

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
                ZStack{
                    Image(uiImage: entry.viewModel.icon).resizable()
                        .scaledToFit().frame(width: 36.0, height: 36.0, alignment: .leading)
             
                    Image(systemName: entry.viewModel.statusIcon ?? "")
                        .font(.system(size: 24))
                        .foregroundColor(
                            Color.unknownColor
                        )
                        .background(Color.white.mask(Circle()).padding(4)
                        )
                        .offset(x: 18, y: 0)
                }
                
                Text(entry.viewModel.progressString)
                    .fontWeight(.bold)
                    .font(.system(size: CGFloat(entry.viewModel.progressStringSize)))
                    .foregroundColor(.regularText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top,3)
                    .padding(.trailing, 16)
                    .opacity(entry.viewModel.progressStringAlpha)
                if(entry.viewModel.statusIcon == nil) {
                    ProgressView(progress: CGFloat(entry.viewModel.progressValue))
                        .frame(height:6)
                        .padding(.top,6)
                }
                
            }
        }
    }
}


struct SmallWidgetView : View {
    var entry: HomescreenProvider.Entry

    var body: some View {
        if(entry.configuration.Theme?.identifier ?? "" == Theme.auto.rawValue) {
            InnerSmallWidget(entry: entry)
        } else {
            InnerSmallWidget(entry: entry)
                .environment(
                    \.colorScheme,
                    (entry.configuration.Theme?.identifier ?? "" == Theme.dark.rawValue)
                        ? .dark : .light
                )
        }
    }
}

private struct InnerSmallWidget : View {
    var entry: HomescreenProvider.Entry

    var body: some View {
        ZStack {
            entry.viewModel.bgColor
            BaseWidgetView(entry: entry).padding().padding(.bottom,3)
        }
    }
}


struct MinecraftServerStatusHSWidget_SmallPreview: PreviewProvider {
    static var previews: some View {
        MinecraftServerStatusHSWidgetEntryView(entry: ServerStatusHSSnapshotEntry(date: Date(), configuration: ServerSelectIntent(), viewModel: WidgetEntryViewModel()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

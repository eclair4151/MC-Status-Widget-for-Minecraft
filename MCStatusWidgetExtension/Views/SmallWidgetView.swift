//
//  BaseWidgetView.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 10/10/24.
//


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
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    private var progressBgOpacity: Double {
        if widgetRenderingMode == .accented {
            return 0.6
        } else {
            return 1.0
        }
    }
    
    private var progressBgColor: Color {
        if widgetRenderingMode == .accented {
            return Color.primary
        } else {
            return Color.gray
        }
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.viewModel.serverName)
                    .fontWeight(.semibold)
                    .foregroundColor(.semiTransparentText)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .lineLimit(1)
                    .font(.system(size: 16))
                    .widgetAccentable()
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
                    // hack for allowing widgetAccentedRenderingMode
                    if #available(iOSApplicationExtension 18.0, *) {
                        Image(uiImage: entry.viewModel.icon)
                            .resizable()
                            .widgetAccentedRenderingMode(WidgetAccentedRenderingMode.accentedDesaturated)
                            .scaledToFit().frame(width: 36.0, height: 36.0, alignment: .leading)
                            .widgetAccentable()
                    } else {
                        Image(uiImage: entry.viewModel.icon)
                            .resizable()
                            .scaledToFit().frame(width: 36.0, height: 36.0, alignment: .leading)
                    }
                    
                    if let statusIcon = entry.viewModel.statusIcon, !statusIcon.isEmpty {
                        Image(systemName: statusIcon)
                            .font(.system(size: 24))
                            .foregroundColor( Color.unknownColor )
                            .background(Color.white.mask(Circle()).padding(4)
                            )
                            .offset(x: 18, y: 0)
                            .widgetAccentable()
                    }
                    
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
                    CustomProgressView(progress: CGFloat(entry.viewModel.progressValue), bgColor: self.progressBgColor, bgOpactiy: self.progressBgOpacity)
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
        if(entry.configuration.Theme == nil || entry.configuration.Theme?.id ?? "" == Theme.auto.rawValue) {
            BaseWidgetView(entry: entry).padding().padding(.bottom,3)
        } else {
            BaseWidgetView(entry: entry).padding().padding(.bottom,3)
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
        MinecraftServerStatusHSWidgetEntryView(entry: ServerStatusHSSnapshotEntry(date: Date(), configuration: ServerSelectWidgetIntent(), viewModel: WidgetEntryViewModel()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

//
//  RectangularAccessoryWidgetView.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 10/11/24.
//


//
//  CircularAccessoryWidgetView.swift
//  MinecraftServerStatusHSWidgetExtension
//
//  Created by Tomer Shemesh on 10/4/22.
//  Copyright © 2022 ShemeshApps. All rights reserved.
//

import Foundation
import SwiftUI
import Intents
import WidgetKit


struct RectangularAccessoryWidgetView : View {
    var entry: LockscreenProvider.Entry

    var body: some View {
        
#if !targetEnvironment(macCatalyst)
        Gauge (value: entry.viewModel.progressValue) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 0) {
                    if let statusIcon = entry.viewModel.statusIcon {
                        Image(systemName: statusIcon)
                            .font(.system(size: 20))
                            .padding(2).widgetAccentable()
                    } else {
                        Image(uiImage: entry.viewModel.icon).resizable()
                            .scaledToFit().frame(width: 18.0, height: 18.0).padding(0).widgetAccentable()
                    }
                    Text(entry.viewModel.serverName).font(.headline).padding(.leading, 5)
                    Spacer()
                    Button(intent: RefreshWidgetIntent()) {
                        HStack(spacing: 4) { // Adjust spacing as needed
                            Image(systemName: "arrow.clockwise")
                                .imageScale(.medium).frame(width: 5, height: 5).scaleEffect(CGSize(width: 0.70, height: 0.70), anchor: .center).foregroundColor(.veryTransparentText) // You can adjust the size as needed
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            
                Text(entry.viewModel.progressString)
            }
            
        }
        .gaugeStyle(.accessoryLinearCapacity)
         
#endif
    }
}


#if !targetEnvironment(macCatalyst)
struct MinecraftServerStatusHSWidget_RectanglePreview: PreviewProvider {
    static var previews: some View {
        MinecraftServerStatusLSWidgetEntryView(entry: ServerStatusLSSnapshotEntry(date: Date(), configuration: ServerSelectNoThemeWidgetIntent(), viewModel: WidgetEntryViewModel()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
#endif

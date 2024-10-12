//
//  CircularAccessoryWidgetView1.swift
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


struct CircularAccessoryWidgetView1 : View {
    var entry: LockscreenProvider.Entry

    var body: some View {
        
#if !targetEnvironment(macCatalyst)
        Gauge (value: entry.viewModel.progressValue) {
            VStack(spacing: 1) {
                Button(intent: RefreshWidgetIntent()) {
                    HStack(spacing: 4) { // Adjust spacing as needed
                        if let statusIcon = entry.viewModel.statusIcon {
                            Image(systemName: statusIcon)
                                .font(.system(size: 20))
                                .foregroundColor(
                                    Color.unknownColor
                                )
                                .background(Color.white.mask(Circle()).padding(2)
                                )
                             
                        } else if(entry.viewModel.viewType == .Unconfigured) {
                            Text("Edit Widget").padding(2) .multilineTextAlignment(.center)
                        } else {
                            Image(uiImage: entry.viewModel.icon).resizable()
                                .scaledToFit().frame(width: 20.0, height: 20.0).padding(0)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                Text(entry.viewModel.progressString)
            }
            
        }
        .gaugeStyle(.accessoryCircularCapacity)

    #endif
    }
}


#if !targetEnvironment(macCatalyst)
struct MinecraftServerStatusHSWidget_CircularPreview: PreviewProvider {
    static var previews: some View {
        MinecraftServerStatusLSWidgetEntryView(entry: ServerStatusLSSnapshotEntry(date: Date(), configuration: ServerSelectNoThemeWidgetIntent(), viewModel: WidgetEntryViewModel()))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
#endif

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


struct CircularAccessoryWidgetView : View {
    var entry: ProviderTest.Entry

    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
        
           
            Gauge (value: entry.viewModel.progressValue) {
                
                if let statusIcon = entry.viewModel.statusIcon {
                    Image(systemName: statusIcon)
                        .font(.system(size: 24))
                        .foregroundColor(
                            Color.unknownColor
                        )
                        .background(Color.white.mask(Circle()).padding(4)
                        )
                     
                } else if(entry.viewModel.isDefaultView) {
                    Text("Edit Widget").padding(2) .multilineTextAlignment(.center)
                } else {
                    
                    Image(uiImage: entry.viewModel.icon).resizable()
                        .scaledToFit().frame(width: 25.0, height: 25.0).padding(0)
                }
            }
            .gaugeStyle(.accessoryCircularCapacity)
        } else {
            Text("4Not implemented")
        }
    }
}


@available(iOSApplicationExtension 16.0, *)
struct MinecraftServerStatusHSWidget_CircularPreview: PreviewProvider {
    static var previews: some View {
        MinecraftServerStatusLSWidgetEntryView(entry: ServerStatusSnapshotEntry2(date: Date(), configuration: ServerSelectNoThemeIntent(), viewModel: WidgetEntryViewModel()))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}

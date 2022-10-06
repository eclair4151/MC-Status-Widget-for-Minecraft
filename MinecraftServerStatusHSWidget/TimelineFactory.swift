//
//  TimelineFactory.swift
//  MinecraftServerStatusHSWidgetExtension
//
//  Created by Tomer Shemesh on 10/6/22.
//  Copyright © 2022 ShemeshApps. All rights reserved.
//

import Foundation
import WidgetKit
import UIKit

protocol TimelineProviderFactoryProtocol {
    func addTimelineEntry(entryDate: Date, vm: WidgetEntryViewModel)
    func completeTimeline()
    func getServer() -> ServerIntentType?
    func isPreview() -> Bool
    func getTheme() -> Theme
    func shouldGenerateFutureEntires() -> Bool
}


class LSWidgetTimelineProvider: TimelineProviderFactoryProtocol {
     
    var entries: [ServerStatusLSSnapshotEntry] = []
    private let configuration: ServerSelectNoThemeIntent
    private let context: TimelineProviderContext
    private let refreshInterval: Int
    private let completion: (Timeline<ServerStatusLSSnapshotEntry>) -> ()
    
    init(context: TimelineProviderContext, configuration: ServerSelectNoThemeIntent, refreshInterval: Int, completion: @escaping (Timeline<ServerStatusLSSnapshotEntry>) -> ()) {
        self.configuration = configuration
        self.context = context
        self.refreshInterval = refreshInterval
        self.completion = completion
    }
    
    func addTimelineEntry(entryDate: Date, vm: WidgetEntryViewModel) {
        let entry = ServerStatusLSSnapshotEntry(date: entryDate, configuration: configuration, viewModel: vm)
        entries.append(entry)
    }
    
    func completeTimeline() {
        let futureDate = Calendar.current.date(byAdding: .minute, value: refreshInterval, to: Date())!

        let timeline = Timeline(entries:entries, policy: .after(futureDate))
        self.completion(timeline)
    }
    
    func getServer() -> ServerIntentType? {
        configuration.Server
    }
    
    func isPreview() -> Bool {
        return context.isPreview
    }
    
    func getTheme() -> Theme {
        return Theme.auto
    }
    
    func shouldGenerateFutureEntires() -> Bool {
        return false
    }
}



class HSWidgetTimelineProvider: TimelineProviderFactoryProtocol {
        
    var entries: [ServerStatusHSSnapshotEntry] = []
    private let configuration: ServerSelectIntent
    private let context: TimelineProviderContext
    private let refreshInterval: Int
    private let completion: (Timeline<ServerStatusHSSnapshotEntry>) -> ()
    
    init(context: TimelineProviderContext, configuration: ServerSelectIntent, refreshInterval: Int, completion: @escaping (Timeline<ServerStatusHSSnapshotEntry>) -> ()) {
        self.configuration = configuration
        self.context = context
        self.refreshInterval = refreshInterval
        self.completion = completion
    }
    
    func addTimelineEntry(entryDate: Date, vm: WidgetEntryViewModel) {
        let entry = ServerStatusHSSnapshotEntry(date: entryDate, configuration: configuration, viewModel: vm)
        entries.append(entry)
    }
    
    func completeTimeline() {
        let futureDate = Calendar.current.date(byAdding: .minute, value: refreshInterval, to: Date())!

        let timeline = Timeline(entries:entries, policy: .after(futureDate))
        self.completion(timeline)
    }
    
    func getServer() -> ServerIntentType? {
        configuration.Server
    }
    
    func isPreview() -> Bool {
        return context.isPreview
    }
    
    func getTheme() -> Theme {
        return Theme(rawValue: configuration.Theme?.identifier ?? "Auto") ?? Theme.auto
    }
    
    func shouldGenerateFutureEntires() -> Bool {
        return true
    }
}

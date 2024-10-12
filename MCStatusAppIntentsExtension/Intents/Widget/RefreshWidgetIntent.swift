//
//  RefreshWidgetIntent.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 10/11/24.
//


import AppIntents
import WidgetKit

struct RefreshWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Widget"
    static var isDiscoverable: Bool = false
    func perform() async throws -> some IntentResult {
//        try await Task.sleep(nanoseconds: UInt64(10) * NSEC_PER_SEC)
        return .result()
    }
}



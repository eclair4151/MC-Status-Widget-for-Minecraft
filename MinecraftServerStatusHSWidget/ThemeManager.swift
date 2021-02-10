//
//  ThemeManager.swift
//  MinecraftServerStatus
//
//  Created by Tomer on 2/7/21.
//  Copyright © 2021 ShemeshApps. All rights reserved.
//

import Foundation
import SwiftUI

enum Theme:String, CaseIterable {
    case dark = "Dark"
    case light = "Light"
    case blue = "Blue"
    case green = "Green"
    case red = "Red"
    case auto = "Auto"
}



extension Color {
    static let semiTransparentText = Color("SemiTransparentText")
    static let veryTransparentText = Color("VeryTransparentText")
    static let regularText = Color("RegularText")
    static let progressBarColor = Color("ProgressBarColor")
    static let unknownColor = Color("UnknownColor")
    static let progressBarBgColor = Color("ProgressBarBgColor")
    static let widgetBackground = Color("WidgetBackground")
    static let widgetBackgroundGreen = Color("WidgetBackgroundGreen")
    static let widgetBackgroundBlue = Color("WidgetBackgroundBlue")
    static let widgetBackgroundRed = Color("WidgetBackgroundRed")
}

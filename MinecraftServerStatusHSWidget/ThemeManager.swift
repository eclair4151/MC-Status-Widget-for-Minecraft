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
    case auto = "Auto"
}



extension Color {
    static let semiTransparentText = Color("SemiTransparentText")
    static let veryTransparentText = Color("VeryTransparentText")
    static let regularText = Color("RegularText")
    static let progressBarColor = Color("ProgressBarColor")

}

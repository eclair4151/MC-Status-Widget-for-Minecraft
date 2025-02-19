import SwiftUI

struct Feature: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let iconColor: Color
    
    init(_ title: String, description: String, icon: String, iconColor: Color) {
        self.title = title
        self.description = description
        self.icon = icon
        self.iconColor = iconColor
    }
}

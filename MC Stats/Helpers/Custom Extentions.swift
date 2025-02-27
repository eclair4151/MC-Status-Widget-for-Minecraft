import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static let appBackgroundColor = Color("AppBackgroundColor")
    static let MOTDBackground = Color("MOTDBackground")
    static let secondaryTextColor = Color("SecondaryTextColor")
    static let tertiaryTextColor = Color("TertiaryTextColor")
    static let unknownColor = Color("UnknownColor")
    //    static let widgetBackground = Color("WidgetBackground")
    
    //    static let statusBackgroundYellow = Color("StatusBackgroundYellow")
    //    static let statusBackgroundGreen = Color("StatusBackgroundGreen")
    //    static let standoutPillGrey = Color("StandoutPillGrey")
    //    static let placeholderGrey = Color("PlaceholderGrey")
    //    static let serverIconBackground = Color("ServerIconBackground")
    
    //    static let semiTransparentText = Color("SemiTransparentText")
    //    static let veryTransparentText = Color("VeryTransparentText")
    //    static let regularText = Color("RegularText")
    //    static let progressBarColor = Color("ProgressBarColor")
    //    static let progressBarBgColor = Color("ProgressBarBgColor")
    //    static let widgetBackgroundGreen = Color("WidgetBackgroundGreen")
    //    static let widgetBackgroundBlue = Color("WidgetBackgroundBlue")
    //    static let widgetBackgroundRed = Color("WidgetBackgroundRed")
}

extension Font {
    static var size: CGFloat {
#if os(tvOS)
        40
#else
        13
#endif
    }
    
    static let minecraftFont = Font.custom("Minecraft-Regular", size: size)
}

#if os(macOS)
extension NSImage {
    func pngData() -> Data? {
        guard
            let tiffData = self.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiffData)
        else {
            return nil
        }
        
        return bitmap.representation(using: .png, properties: [:])
    }
}
#endif

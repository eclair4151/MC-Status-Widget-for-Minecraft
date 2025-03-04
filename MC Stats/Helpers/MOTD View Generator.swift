import SwiftUI
import MCStatsDataLayer

extension ServerStatus {
    // Add this method inside the ServerStatus class
    public func generateMOTDView() -> Text {
        // Check for description
        guard let description else {
            return Text("")
        }
        
        // init a var to hold the composed Text view
        var combinedText = Text("")
        
        // Loop through each section in the messageSections
        for section in description.messageSections {
            // Create a Text view for the current section
            var text = Text(section.text)
            text = text.font(Font.minecraftFont)
            
            // Apply formatting based on the section properties
            if section.formatters.contains(.bold) {
                text = text.bold()
            }
            
            if section.formatters.contains(.italic) {
                text = text.italic()
            }
            
            if section.formatters.contains(.underline) {
                text = text.underline()
            }
            
            if section.formatters.contains(.strikethrough) {
                text = text.strikethrough()
            }
            
            // Set the color if available
            if section.color.isEmpty {
                text = text
                    .foregroundStyle(.white)
            } else {
                text = text
                    .foregroundStyle(Color(hex: section.color))
            }
            
            // Append the formatted text to the combinedText
            combinedText = combinedText + text
        }
        
        // Remove the last newline
        return combinedText
    }
}

import SwiftUI

class ImageHelper {
#warning("macOS")
#if os(macOS)
    static func favIconString(_ favIcon: String?) -> NSImage? {
        if let favIconString = favIcon, favIconString != "" {
            let favIconParts = favIconString.split(separator: ",")
            
            guard favIconParts.count == 2 else {
                return nil
            }
            
            if let decodedData = Data(base64Encoded: String(favIconParts[1]), options: .ignoreUnknownCharacters) {
                return NSImage(data: decodedData)
            }
        }
        
        return nil
    }
#else
    static func favIconString(_ favIcon: String?) -> UIImage? {
        if let favIconString = favIcon, favIconString != "" {
            let favIconParts = favIconString.split(separator: ",")
            
            guard favIconParts.count == 2 else {
                return nil
            }
            
            if let decodedData = Data(base64Encoded: String(favIconParts[1]), options: .ignoreUnknownCharacters) {
                return UIImage(data: decodedData)
            }
        }
        
        return nil
    }
#endif
}

import SwiftUI

class ImageHelper {
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
}

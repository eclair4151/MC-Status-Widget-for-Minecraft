import Foundation

enum MCIntentError: Swift.Error, CustomLocalizedStringResourceConvertible {
    case DB_ID_MISSING,
         UNKNOWN_ERROR,
         NO_SERVERS
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .UNKNOWN_ERROR: "Unknown error."
        case .DB_ID_MISSING: "Error: Server not found"
        case .NO_SERVERS: "No servers available. Add one in the app to get started!"
        }
    }
}

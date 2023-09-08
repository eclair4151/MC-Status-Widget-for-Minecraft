//
//  IntentErrors.swift
//  MC Status
//
//  Created by Tomer Shemesh on 9/1/23.
//

import Foundation

enum MCIntentError: Swift.Error, CustomLocalizedStringResourceConvertible {
    case DB_ID_MISSING
    case UNKNOWN_ERROR
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .UNKNOWN_ERROR: return "Unknown error."
        case .DB_ID_MISSING: return "Error: Server not found"
        }
    }
}

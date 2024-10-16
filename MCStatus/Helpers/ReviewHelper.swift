import StoreKit
import SwiftUI

class ReviewHelper {
    
    // UserDefaults keys
    private enum UserDefaultKey: String {
        case launchCount
        case lastRequestTimestamp
        case lastVersion
    }
    
    @AppStorage(UserDefaultKey.launchCount.rawValue) private var launchCount: Int = 0
    @AppStorage(UserDefaultKey.lastRequestTimestamp.rawValue) private var lastRequestTimestamp: TimeInterval = 0
    @AppStorage(UserDefaultKey.lastVersion.rawValue) private var lastVersion: String = ""
    
    private let currentVersion: String
    
    init() {
        // Get the current app version from the Info.plist
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.currentVersion = version
        } else {
            self.currentVersion = "1.0" // Fallback version
        }
    }
    
    // Call this method when the app launches
    func appLaunched() {
        launchCount += 1
    }
    
    // Check if the review prompt should be shown
    func shouldShowRequestView() -> Bool {
        let isLaunchCountSufficient = launchCount >= 5
        let isTimeElapsed = isTimeSinceLastRequestExceeded()
        let isNewVersion = lastVersion != currentVersion
        
        return isLaunchCountSufficient && isTimeElapsed && isNewVersion
    }
    
    // Call this method when the review prompt has been shown
    func didShowReview() {
        lastRequestTimestamp = Date().timeIntervalSince1970 // Store current time as Unix timestamp
        lastVersion = currentVersion
    }
    
    
    // Check if six months have passed since the last request
    private func isTimeSinceLastRequestExceeded() -> Bool {
        // Calculate the timestamp for six months ago
        let sixMonthsInSeconds: TimeInterval = 6 * 30 * 24 * 60 * 60 // Approximation of 6 months
        let sixMonthsAgo = Date().timeIntervalSince1970 - sixMonthsInSeconds
        
        return lastRequestTimestamp < sixMonthsAgo
    }
}

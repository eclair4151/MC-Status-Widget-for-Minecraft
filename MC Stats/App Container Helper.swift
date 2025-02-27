import Foundation
import MCStatsDataLayer

extension AppContainer {
    func deleteItems(at offsets: IndexSet) {
        offsets.makeIterator().forEach { pos in
            if let serverVM = servers?[pos] {
                modelContext.delete(serverVM.server)
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
        servers?.remove(atOffsets: offsets)
    }
    
    func checkForAutoReload() {
        let currentTime = Date()
        
        let timeInterval = currentTime.timeIntervalSince(lastRefreshTime)
        
        guard timeInterval > 60 else {
            return
        }
        
        // >60 seconds passed
        reloadData(forceRefresh: true)
        
        refreshAllWidgets()
    }
    
#if !os(watchOS)
    func checkForPendingDeepLink() {
        guard
            let pendingDeepLink,
            let serverID = UUID(uuidString: pendingDeepLink),
            let vm = serverVMCache[serverID]
        else {
            return
        }
        
        self.pendingDeepLink = nil
        goToServerView(vm)
    }
    func checkForAppReviewRequest() {
        reviewHelper.appLaunched()
        
        // Not showing if no servers were added
        if servers?.isEmpty ?? true {
            return
        }
        
        if reviewHelper.shouldShowRequestView() {
            Task {
                try await Task.sleep(for: .seconds(6))
#if !os(tvOS)
                requestReview()
#endif
                reviewHelper.didShowReview()
            }
        }
    }
    
    func goToServerView(_ vm: ServerStatusVM) {
        // check if user has disabled deep links, if so just go to main list
        if !UserDefaultsHelper.shared.get(for: .openToSpecificServer, defaultValue: true) {
            self.nav.removeLast(self.nav.count)
            return
        }
        
        // go to server view
        // First, check if a server is already displayed and update it if so
        if self.nav.isEmpty {
            self.nav.append(vm)
        } else {
            self.nav.removeLast(self.nav.count)
            
            Task {
                // hack! otherwise data won't refresh correctly
                self.nav.append(vm)
            }
        }
    }
#endif
}

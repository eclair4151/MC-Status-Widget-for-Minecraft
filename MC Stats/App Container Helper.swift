import Foundation

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
}

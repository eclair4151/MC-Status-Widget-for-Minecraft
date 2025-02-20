import SwiftUI
import WidgetKit
import MCStatusDataLayer
import SwiftData

struct LockscreenProvider: AppIntentTimelineProvider {
    let widgetType: LSWidgetType
    
    init(widgetType: LSWidgetType) {
        self.widgetType = widgetType
    }
    
    // Required for Apple Watch complications
    func recommendations() -> [AppIntentRecommendation<ServerSelectNoThemeWidgetIntent>] {
        let container = SwiftDataHelper.getModelContainter()
        let servers = SwiftDataHelper.getSavedServersBg(container)
        
        return servers.map {
            let entity = ServerIntentTypeAppEntity(
                id: $0.id.uuidString,
                displayString: $0.name
            )
            
            let intent = ServerSelectNoThemeWidgetIntent()
            intent.Server = entity
            
            let widgetNamePostfix = if self.widgetType == .OnlyImage {
                " (No Text)"
            } else {
                ""
            }
            
            let watchComplicationName = $0.name + widgetNamePostfix
            
            return AppIntentRecommendation(
                intent: intent,
                description: watchComplicationName
            )
        }
    }
    
    // this view is for when the widget has been added the the homescreen, but the user has not selected a server/theme
    func placeholder(in context: Context) -> ServerStatusLSSnapshotEntry {
        var vm = WidgetEntryVM()
        vm.setForUnconfiguredView()
        
        return ServerStatusLSSnapshotEntry(
            date: Date(),
            configuration: ServerSelectNoThemeWidgetIntent(),
            vm: vm
        )
    }
    
    // if context.isPreview is true, this is the view to show when someone clicked add widget
    // Just show preview with placeholder data
    // if it is false, yo ushould actually load the current state of the view by getting the status
    func snapshot(
        for configuration: ServerSelectNoThemeWidgetIntent,
        in context: Context
    ) async -> ServerStatusLSSnapshotEntry {
        var vm = WidgetEntryVM()
        
        let container = SwiftDataHelper.getModelContainter()
        
        if !context.isPreview, let (server, serverStatus) = await loadTimelineData(from: container, with: configuration) {
            let serverIcon = ImageHelper.convertFavIconString(serverStatus.favIcon) ?? UIImage(named: "DefaultIcon")!
            
            vm = WidgetEntryVM(
                serverName: server.name,
                status: serverStatus,
                lastUpdated: "now",
                serverIcon: serverIcon,
                theme: .auto
            )
        }
        
        if context.isPreview {
            vm.viewType = .Preview
        }
        
        return ServerStatusLSSnapshotEntry(
            date: Date(),
            configuration: configuration,
            vm: vm
        )
    }
    
    func loadTimelineData(
        from container: ModelContainer,
        with configuration: ServerSelectNoThemeWidgetIntent
    ) async -> (SavedMinecraftServer, ServerStatus)? {
        // Step 1: load server from DB
        guard
            let serverId = configuration.Server?.id,
            let uuid = UUID(uuidString: serverId),
            let server = await SwiftDataHelper.getSavedServerById(uuid, from: container)
        else {
            return nil
        }
        
        // Step 2: load status
#if os(watchOS)
        let statusResult = await WatchServerStatusChecker().checkServerAsync(server)
#else
        let statusResult = await ServerStatusChecker.checkServer(server)
#endif
        return (server, statusResult)
    }
    
    func timeline(
        for configuration: ServerSelectNoThemeWidgetIntent,
        in context: Context
    ) async -> Timeline<ServerStatusLSSnapshotEntry> {
        var entries: [ServerStatusLSSnapshotEntry] = []
        let currentDate = Date()
        let futureDate = Calendar.current.date(byAdding: .minute, value: 10, to: Date())!
        
        let container = SwiftDataHelper.getModelContainter()
        
        guard let (server, serverStatus) = await loadTimelineData(from: container, with: configuration) else {
            // nothing configured yet?
            var vm = WidgetEntryVM()
            vm.setForUnconfiguredView()
            
            let serverCount = await SwiftDataHelper.getSavedServers(container).count
            
            if serverCount == 0 {
                // if user has nothing in the DB tell them to open the app
                vm.serverName = "Open App"
            }
            
            let entry = ServerStatusLSSnapshotEntry(
                date: currentDate,
                configuration: configuration,
                vm: vm
            )
            
            entries.append(entry)
            
            return Timeline(
                entries: entries,
                policy: .after(futureDate)
            )
        }
        
        let serverIcon = ImageHelper.convertFavIconString(serverStatus.favIcon) ?? UIImage(named: "DefaultIcon")!
        
        let vm = WidgetEntryVM(
            serverName: server.name,
            status: serverStatus,
            lastUpdated: "",
            serverIcon: serverIcon,
            theme: .auto
        )
        
        let entry = ServerStatusLSSnapshotEntry(
            date: currentDate,
            configuration: configuration,
            vm: vm
        )
        
        entries.append(entry)
        
        return Timeline(
            entries: entries,
            policy: .after(futureDate)
        )
    }
}

import ScrechKit

@main
struct MCStatsWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
#if !os(watchOS)
        MinecraftServerStatusHSWidget()
#endif
        MinecraftServerStatusLSWidget1()
        MinecraftServerStatusLSWidget2()
    }
}

#if canImport(WidgetKit)
import WidgetKit
#endif

func refreshAllWidgets() {
#if canImport(WidgetKit)
    WidgetCenter.shared.reloadAllTimelines()
#endif
}

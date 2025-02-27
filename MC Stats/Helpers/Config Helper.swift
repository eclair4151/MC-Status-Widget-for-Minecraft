import MCStatsDataLayer

class ConfigHelper {
    static func getServerCheckerConfig() -> ServerCheckerConfig {
        ServerCheckerConfig(
            sortUsers: UserDefaultsHelper.shared.get(
                for: .sortUsersByName,
                defaultValue: true
            )
        )
    }
}

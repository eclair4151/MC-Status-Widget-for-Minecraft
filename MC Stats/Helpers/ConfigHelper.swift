import MCStatusDataLayer

class ConfigHelper {
    static func getServerCheckerConfig() -> ServerCheckerConfig {
        ServerCheckerConfig(
            sortUsers: UserDefaultHelper.shared.get(
                for: .sortUsersByName,
                defaultValue: true
            )
        )
    }
}

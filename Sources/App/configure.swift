import Vapor
import Leaf
import FluentMySQL

// swift run Run --hostname 192.168.1.144 --port 8000
// swift run Run --hostname 192.168.1.144 --port 9000

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentMySQLProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Register Leaf
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    // configure MySQL
    let mysqlConfig = MySQLDatabaseConfig(
      hostname: "127.0.0.1",
      port: 8889,
      username: "root",
      password: "root",
      database: "myvapor"
    )
    services.register(mysqlConfig)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: TestModel.self, database: .mysql)
    services.register(migrations)
}

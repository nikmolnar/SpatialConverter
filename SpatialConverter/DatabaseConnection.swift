import Foundation
import Security

@objc class DatabaseConnection: NSObject {
    @objc dynamic var name: String
    @objc dynamic var host: String = "127.0.0.1"
    var port: Int = 5432
    @objc dynamic var username: String
    private var _password: String? = nil
    var passwordKeychainKey: String?
    @objc dynamic var database: String
    var schema: String = "public"
    
    @objc var password: String? {
        get {
            if _password == nil && passwordKeychainKey != nil {
                // Todo: load password from keychain
            }
            return _password
        }
        set(password) {
            _password = password
            // Todo: set password in keychain
        }
    }
    
    init(name: String, username: String, database: String) {
        self.name = name
        self.username = username
        self.database = database
    }
    
    init(name: String, host: String, port: Int, username: String, password: String?, database: String, schema: String) {
        self.name = name
        self.username = username
        self.database = database
        self.host = host
        self.port = port
        self.schema = schema
        
        super.init()
        
        if let trimmedPassword = password?.trimmingCharacters(in: .whitespacesAndNewlines) {
            self.password = trimmedPassword.isEmpty ? nil : trimmedPassword
        }
    }
}

extension DatabaseConnection: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return DatabaseConnection(
            name: name, host: host, port: port, username: username, password: password, database: database,
            schema: schema
        )
    }
}

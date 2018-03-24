import AppKit

protocol ConnectionPropertiesDelegate {
    func didUpdateProperties(_ connection: DatabaseConnection)
}

@objc class ConnectionPropertiesViewController: NSViewController {
    @IBOutlet weak var connectionNameText: NSTextField!
    @IBOutlet weak var hostText: NSTextField!
    @IBOutlet weak var portText: NSTextField!
    @IBOutlet weak var usernameText: NSTextField!
    @IBOutlet weak var passwordText: NSTextField!
    @IBOutlet weak var schemaCombo: NSComboBox!
    @IBOutlet weak var databaseCombo: NSComboBox!
    @IBOutlet weak var testButton: NSButton!
    @IBOutlet weak var okButton: NSButton!
    
    private var context = 0
    
    var delegate: ConnectionPropertiesDelegate?
    var _connection: DatabaseConnection?
    var currentConnectionParams: (String, Int, String, String)? = nil
    let opQueue = OperationQueue()
    @objc dynamic var isTestingConnection = false
    
    var connection: DatabaseConnection? {
        get {
            return _connection
        }
        set(connection) {
            self._connection = connection?.copy() as? DatabaseConnection
            updateForm()
            schemaCombo.removeAllItems()
            databaseCombo.removeAllItems()
        }
    }
    
    override func viewDidLoad() {
        for control in
            [connectionNameText, hostText, portText, usernameText, passwordText, schemaCombo, databaseCombo]
        {
            control!.delegate = self
        }
        
        self.addObserver(self, forKeyPath: #keyPath(isTestingConnection), options: [.new, .old], context: &context)
    }
    
    deinit {
        removeObserver(self, forKeyPath: "isTestingConnection")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &self.context {
            updateButtonState()
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    @IBAction func handleCancel(_ sender: Any) {
        dismissViewController(self)
    }
    
    @IBAction func handleTest(_ sender: Any) {
        isTestingConnection = true
        
        let connectionParams = (
            host: hostText.stringValue,
            port: (portText.objectValue as? Int) ?? 5432,
            username: usernameText.stringValue,
            password: passwordText.stringValue,
            schema: schemaCombo.stringValue,
            database: databaseCombo.stringValue
        )
        
        opQueue.addOperation() {
            let conn = PGConnection()
            let status = conn.connectdb(
                "postgresql://\(connectionParams.username):\(connectionParams.password)@\(connectionParams.host):" +
                "\(connectionParams.port)/\(connectionParams.database)?connect_timeout=60"
            )
            let message = conn.errorMessage()
            conn.close()
            
            DispatchQueue.main.async() {
                let alert = NSAlert()
                if status == .ok {
                    alert.alertStyle = .informational
                    alert.messageText = "Connection successful"
                }
                else {
                    alert.alertStyle = .warning
                    alert.messageText = "Error connecting to database: \(message)"
                }
                alert.runModal()
                
                self.isTestingConnection = false
            }
        }
    }
    
    @IBAction func handleOk(_ sender: Any) {
        if isFormValid() {
            let newConnection = DatabaseConnection(
                name: connectionNameText.stringValue, host: hostText.stringValue,
                port: Int(portText.stringValue) ?? 5432, username: usernameText.stringValue,
                password: passwordText.stringValue, database: databaseCombo.stringValue,
                schema: schemaCombo.stringValue
            )
            delegate?.didUpdateProperties(newConnection)
            dismissViewController(self)
        }
    }
    
    private func updateForm() {
        connectionNameText.stringValue = (connection?.name) ?? ""
        hostText.stringValue = (connection?.host) ?? "127.0.0.1"
        portText.stringValue = connection == nil ? "5432" : String(describing: connection?.port)
        usernameText.stringValue = (connection?.username) ?? ""
        passwordText.stringValue = (connection?.password) ?? ""
        schemaCombo.stringValue = (connection?.schema) ?? "public"
        databaseCombo.stringValue = (connection?.database) ?? ""
        
        updateButtonState()
    }
    
    private func updateButtonState() {
        if isFormValid(){
            okButton.isEnabled = true
            okButton.highlight(true)
            testButton.isEnabled = true
        }
        else {
            okButton.isEnabled = false
            testButton.isEnabled = false
        }
        testButton.isEnabled = isFormValid() && !isTestingConnection ? true : false
    }
    
    private func isFormValid() -> Bool {
        let requiredInputs = [
            connectionNameText, hostText, portText, usernameText, schemaCombo, databaseCombo
        ]
        
        for input in requiredInputs {
            if input!.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return false
            }
        }
        return true
    }
    
    private func canConnect() -> Bool {
        for input in [hostText, portText, usernameText, passwordText] {
            if input!.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return false
            }
        }
        return true
    }
    
    private func refreshDatabaseInfo() {
        let connectionParams = (
            host: hostText.stringValue,
            port: (portText.objectValue as? Int) ?? 5432,
            username: usernameText.stringValue,
            password: passwordText.stringValue
        )
        if currentConnectionParams != nil && currentConnectionParams! == connectionParams {
            return
        }
        
        currentConnectionParams = connectionParams
        
        opQueue.addOperation() {
            let conn = PGConnection()
            let status = conn.connectdb(
                "postgresql://\(connectionParams.username):\(connectionParams.password)@\(connectionParams.host):" +
                    "\(connectionParams.port)"
            )
            if status == .bad {
                print(conn.errorMessage())
                return
            }
                
            var schemas: [String] = []
            var result = conn.exec(statement: "SELECT schema_name FROM information_schema.schemata")
            for i in 0..<result.numTuples() {
                if let schema = result.getFieldString(tupleIndex: i, fieldIndex: 0) {
                    schemas.append(schema)
                }
            }
            
            var databases: [String] = []
            result = conn.exec(statement: "SELECT datname FROM pg_database WHERE datistemplate = false")
            for i in 0..<result.numTuples() {
                if let database = result.getFieldString(tupleIndex: i, fieldIndex: 0) {
                    databases.append(database)
                }
            }
            
            if self.currentConnectionParams != nil && self.currentConnectionParams! == connectionParams {
                DispatchQueue.main.async() {
                    self.schemaCombo.removeAllItems()
                    self.schemaCombo.addItems(withObjectValues: schemas.sorted())
                    
                    self.databaseCombo.removeAllItems()
                    self.databaseCombo.addItems(withObjectValues: databases.sorted())
                }
            }
            
            conn.close()
        }
    }
}

extension ConnectionPropertiesViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        updateButtonState()
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        if canConnect() {
            refreshDatabaseInfo()
        }
    }
}

class IntFormatter: Formatter {
    override func string(for value: Any?) -> String? {
        if let intValue = value as? Int {
            return "\(intValue)"
        }
        else {
            return ""
        }
    }
    
    override func getObjectValue(
        _ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
        for string: String?,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool
    {
        if let numericString = string?.filter({c in "0"..."9" ~= c}) {
            if let intValue = Int(numericString) {
                obj?.pointee = intValue as AnyObject
                return true
            }
        }
        
        obj?.pointee = nil
        return true
    }
}

//class ComboBoxArrayDataSource: NSObject, NSComboBoxDataSource {
//    var data: [String] = []
//
//    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
//        return data.first(where: {x in x.starts(with: string)})
//    }
//
//    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
//        if let index = data.index(where: {x in x == string}) {
//            return index
//        }
//        return NSNotFound
//    }
//
//    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
//        return data[index]
//    }
//
//    func numberOfItems(in comboBox: NSComboBox) -> Int {
//        return data.count
//    }
//}

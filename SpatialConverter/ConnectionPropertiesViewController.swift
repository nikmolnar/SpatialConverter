import AppKit

protocol ConnectionPropertiesDelegate {
    func didUpdateProperties(_ connection: DatabaseConnection)
}

class ConnectionPropertiesViewController: NSViewController {
    var delegate: ConnectionPropertiesDelegate?
    var _connection: DatabaseConnection?
    var currentConnectionParams: (String, Int, String, String)? = nil
    let opQueue = OperationQueue()
    
    @IBOutlet weak var connectionNameText: NSTextField!
    @IBOutlet weak var hostText: NSTextField!
    @IBOutlet weak var portText: NSTextField!
    @IBOutlet weak var usernameText: NSTextField!
    @IBOutlet weak var passwordText: NSTextField!
    @IBOutlet weak var schemaCombo: NSComboBox!
    @IBOutlet weak var databaseCombo: NSComboBox!
    @IBOutlet weak var okButton: NSButton!
    
    var requiredInputs: [NSControl] {
        return [connectionNameText, hostText, portText, usernameText, schemaCombo, databaseCombo]
    }
    
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
        }
        else {
            okButton.isEnabled = false
        }
    }
    
    private func isFormValid() -> Bool {
        for input in requiredInputs {
            if input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
    
    override func viewDidLoad() {
        for control in
            [connectionNameText, hostText, portText, usernameText, passwordText, schemaCombo, databaseCombo]
        {
            control!.delegate = self
        }
    }
    
    @IBAction func handleCancel(_ sender: Any) {
        dismissViewController(self)
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
        return false
    }
}

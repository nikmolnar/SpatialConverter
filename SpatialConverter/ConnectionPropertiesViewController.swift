import AppKit

protocol ConnectionPropertiesDelegate {
    func didUpdateProperties(_ connection: DatabaseConnection)
}

class ConnectionPropertiesViewController: NSViewController {
    var delegate: ConnectionPropertiesDelegate?
    var _connection: DatabaseConnection?
    
    @IBOutlet weak var connectionNameText: NSTextField!
    @IBOutlet weak var hostText: NSTextField!
    @IBOutlet weak var portText: NSTextField!
    @IBOutlet weak var usernameText: NSTextField!
    @IBOutlet weak var passwordText: NSTextField!
    @IBOutlet weak var schemaCombo: NSComboBox!
    @IBOutlet weak var databaseCombo: NSComboBox!
    
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
    }
    
    private func isFormValid() -> Bool {
        for input in requiredInputs {
            if input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return false
            }
        }
        return true
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
        print("...")
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
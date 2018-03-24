import AppKit

class DatabaseConnectionsViewController: NSViewController {
    @IBOutlet var connectionsArrayController: NSArrayController!
    @objc dynamic var connections: NSArray = []
    var connectionPropertiesViewController: ConnectionPropertiesViewController?
    var selectedObject: DatabaseConnection?
    
    override func viewDidLoad() {
        connectionsArrayController.addObject(DatabaseConnection(name: "Test", username: "Foo", database: "Bar"))
        connectionsArrayController.addObject(DatabaseConnection(name: "Environmental Reporter", username: "env", database: "env"))
        
        connectionPropertiesViewController = storyboard!.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier("connectionPropertiesSheet")
        ) as? ConnectionPropertiesViewController
        connectionPropertiesViewController?.delegate = self
    }
    
    private func saveConnections() {
        // Todo
    }
    
    @IBAction func handleDoubleClick(_ sender: NSTableView) {
        if !connectionsArrayController.selectedObjects.isEmpty {
            selectedObject = connectionsArrayController.selectedObjects[0] as? DatabaseConnection
            presentViewControllerAsSheet(connectionPropertiesViewController!)
            connectionPropertiesViewController?.connection = selectedObject
        }
    }
    
    @IBAction func handleAddRemove(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            presentViewControllerAsSheet(connectionPropertiesViewController!)
            selectedObject = nil
            connectionPropertiesViewController!.connection = nil
        case 1:
            connectionsArrayController.remove(sender)
            saveConnections()
        default:
            break
        }
    }
}

extension DatabaseConnectionsViewController: ConnectionPropertiesDelegate {
    func didUpdateProperties(_ connection: DatabaseConnection) {
        if selectedObject == nil {
            connectionsArrayController.addObject(connection)
        }
        else {
            selectedObject!.name = connection.name
            selectedObject!.host = connection.host
            selectedObject!.port = connection.port
            selectedObject!.username = connection.username
            selectedObject!.password = connection.password
            selectedObject!.schema = connection.schema
            selectedObject!.database = connection.database
        }
    }
}

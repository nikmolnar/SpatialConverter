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

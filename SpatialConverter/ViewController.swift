import Cocoa
import GDAL

class ViewController: NSViewController {
    @IBOutlet weak var dataPopup: NSPopUpButton!
    @IBOutlet weak var containerView: NSView!
    
    var fileDestinationController: NSViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GDAL.Init()
        print(GDAL.version)
        
        fileDestinationController = storyboard!.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier("fileDestinationController")
        ) as? NSViewController
        addChildViewController(fileDestinationController!)
        
        let dragView = fileDestinationController!.view as! FileDragDestinationView
        containerView.addSubview(dragView)
        dragView.delegate = self
    }
    
    @IBAction func openMenuItemSelected(_ sender: Any) {
        chooseFile()
    }
    
    @IBAction func handleDataPopup(_ sender: Any) {
        switch dataPopup.indexOfSelectedItem
        {
        case 1:
            chooseFile()
        case 2:
            print("Connect to database...")
        default:
            return
        }
    }
    
    func loadDatasetFromFile(_ url: URL) {
        var driver: Driver? = nil
        
        if let gdalDriver = GDALIdentifyDriverEx(url.path, 0, nil, nil) {
            driver = Driver(driverH: gdalDriver)
        }
        
        if let driver = driver {
            print(driver.shortName)
        }
    }
    
    func chooseFile() {
        let dialog = NSOpenPanel()
        dialog.title = "Open dataset..."
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            if let url = dialog.url {
                loadDatasetFromFile(url)
            }
        }
        
    }
}

extension ViewController: FileDragDestinationDelegate {
    func didReceiveDrag(_ url: URL) {
        loadDatasetFromFile(url)
    }
}


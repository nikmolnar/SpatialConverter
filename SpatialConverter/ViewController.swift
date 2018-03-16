import Cocoa
import GDAL

class ViewController: NSViewController {
    @IBOutlet weak var dataPopup: NSPopUpButton!
    
    var drivers: [Driver] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(String(cString:GDALVersionInfo("GDAL_RELEASE_NAME")))
        
        loadGDALDrivers()
        
//        guard let storyboard = self.storyboard else {
//            return
//        }
//
//        if let subViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("dropView"))
//            as? NSViewController
//        {
//            self.view = subViewController.view
//        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
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
    
    func loadGDALDrivers() {
        OGRRegisterAll()
        var driverCount: Int32 = OGRGetDriverCount()
        
        for i in 0..<driverCount {
            guard let driver = OGRGetDriver(Int32(i)) else {
                continue
            }
            let driverName = String(cString:OGR_Dr_GetName(driver))
            drivers.append(Driver(label: driverName, driver: .ogr(driver)))
        }
        
        GDALAllRegister()
        driverCount = GDALGetDriverCount()
        
        for i in 0..<driverCount {
            guard let driver = GDALGetDriver(Int32(i)) else {
                continue
            }
            let driverName = String(cString:GDALGetDriverShortName(driver))
            drivers.append(Driver(label: driverName, driver: .gdal(driver)))
        }
    }
    
    func loadDatasetFromFile(_ url: URL) {
        var driver: Driver? = nil
        
        if let gdalDriver = GDALIdentifyDriverEx(url.path, 0, nil, nil) {
            let driverName = String(cString: GDALGetDriverShortName(gdalDriver))
            driver = Driver(label: driverName, driver: .gdal(gdalDriver))
        }
        
        if let driver = driver {
            print(driver.label)
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


import Cocoa
import GDAL

class ViewController: NSViewController {
    @IBOutlet var outputArrayController: NSArrayController!
    
    @objc dynamic var drivers: [Driver] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(String(cString:GDALVersionInfo("GDAL_RELEASE_NAME")))
        
        loadGDALDrivers()
    }
    
    func loadGDALDrivers() {
        OGRRegisterAll()
        let driverCount: Int32 = OGRGetDriverCount()
        
        for i in 0..<driverCount {
            guard let driver = OGRGetDriver(Int32(i)) else {
                continue
            }
            let driverName = String(cString:OGR_Dr_GetName(driver))
            outputArrayController.addObject(Driver(label:driverName, driver:DriverH.ogr(driver)))
        }
        outputArrayController.setSelectionIndex(0)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func performClick(_ sender: Any) {
        let driver = drivers[outputArrayController.selectionIndex]
        print(driver.label)
    }
}


import AppKit
import GDAL

enum DriverH {
    case gdal(GDALDriverH)
    case ogr(OGRSFDriverH)
}

class Driver: NSObject {
    @objc dynamic let label: String
    let driverH: DriverH
    
    init(label: String, driver: DriverH) {
        self.label = label
        self.driverH = driver
        
        super.init()
    }
}

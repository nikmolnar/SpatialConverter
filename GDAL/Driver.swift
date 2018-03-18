import Foundation
import GDAL

enum DriverType {
    case VECTOR, RASTER
}

class Driver {
    let driverH: GDALDriverH
    let shortName: String
    let longName: String
    let driverType: DriverType
    let isReadOnly: Bool
    
    private static func getDrivers() -> [Driver] {
        var drivers: [Driver] = []
        let driverCount = GDALGetDriverCount()
        
        for i in 0..<driverCount {
            guard let driver = GDALGetDriver(Int32(i)) else {
                continue
            }
            
            drivers.append(Driver(driverH: driver))
        }
        
        return drivers
    }
    
    static let allDrivers: [Driver] = getDrivers()
    static let writeDrivers: [Driver] = allDrivers.filter({driver in !driver.isReadOnly})
    
    init(driverH: GDALDriverH) {
        self.driverH = driverH
        self.shortName = String(cString:GDALGetDriverShortName(driverH))
        self.longName = String(cString:GDALGetDriverLongName(driverH))
        
        var isRaster: Bool {
            guard let value = GDALGetMetadataItem(driverH, GDAL_DCAP_RASTER, nil) else { return false }
            return String(cString: value) == "YES"
        }
        var isReadOnly: Bool {
            guard let value = GDALGetMetadataItem(driverH, GDAL_DCAP_CREATE, nil) else { return true }
            return String(cString: value) != "YES"
        }
        
        self.driverType = isRaster ? .RASTER : .VECTOR
        self.isReadOnly = isReadOnly
    }
}

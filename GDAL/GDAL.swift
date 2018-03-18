import Foundation
import GDAL

struct GDAL {
    static var version: String { return String(cString: GDALVersionInfo("GDAL_RELEASE_NAME"))}
    
    static func Init() {
        GDALAllRegister()
    }
}

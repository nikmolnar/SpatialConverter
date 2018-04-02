import Foundation
import GDAL

class DatasetFilePresenter: NSObject, NSFilePresenter {
    var primaryPresentedItemURL: URL?
    var presentedItemURL: URL?
    var presentedItemOperationQueue: OperationQueue {
        return OperationQueue.main
    }
    
    init(primaryURL: URL, ext: String? = nil) {
        self.primaryPresentedItemURL = primaryURL
        
        if ext != nil {
            let parts = primaryURL.path.split(separator: ".")
            let base: String = parts[..<(parts.count-1)].joined()
            self.presentedItemURL = NSURL.fileURL(withPath: "\(base).\(ext!)")
        }
    }
}

class Dataset {
    enum DatasetType {
        case File
        case Database
    }
    
    let driver: Driver
    let datasetH: GDALDatasetH
    var path: String?
    var database: DatabaseConnection?
    
    var type: DatasetType {
        if path != nil {
            return .File
        }
        else {
            return .Database
        }
    }
    
    /**
        Register related file extensions and execute a block within an NSFileCoordinator context
 
        - parameter url: The primary file
    */
    static private func coordinate(_ url: URL, fn: @escaping () -> Void) {
        var extensions: [String] = []
        if let docTypes = getInfo().value(forKey: "CFBundleDocumentTypes") as? Array<NSDictionary> {
            for docType in docTypes {
                if let typeExts = docType.value(forKey: "CFBundleTypeExtensions") as? Array<String> {
                    for ext in typeExts {
                        extensions.append(ext)
                    }
                }
            }
        }
        if extensions.isEmpty {
            print("Could not load any file type extensions from Info.plist")
        }
        
        for ext in extensions {
            NSFileCoordinator.addFilePresenter(DatasetFilePresenter(primaryURL: url, ext: ext))
        }
        
        let coordinator = NSFileCoordinator(filePresenter: DatasetFilePresenter(primaryURL: url))
        coordinator.coordinate(with: [.readingIntent(with: url)], queue: OperationQueue.main) { _ in fn() }
    }
    
    static func open(_ url: URL, driver: Driver?, fn: @escaping (Dataset?) -> Void) {
        coordinate(url) {
            if driver != nil {
                let datasetH: GDALDatasetH? = withArrayOfCStrings([driver!.shortName]) {
                    stringArray in
                    return GDALOpenEx(url.path, 0, stringArray, nil, nil)
                }
                fn(datasetH == nil ? nil : Dataset(datasetH!, driver: nil, path: url.path))
            }
            else if let datasetH = GDALIdentifyDriverEx(url.path, 0, nil, nil) {
                fn(Dataset(datasetH, driver: nil, path: url.path))
            }
            else {
                fn(nil)
            }
        }
    }
    
    static func open(_ url: URL, fn: @escaping(Dataset?) -> Void) {
        if let gdalDriver = GDALIdentifyDriverEx(url.path, 0, nil, nil) {
            let driver = Driver(driverH: gdalDriver)
            Dataset.open(url, driver: driver) { dataset in fn(dataset) }
        }
        else {
            fn(nil)
        }
    }
    
    init(_ datasetH: GDALDatasetH, driver: Driver? = nil, path: String? = nil) {
        self.datasetH = datasetH
        self.path = path
        
        if driver != nil {
            self.driver = driver!
        }
        else {
            self.driver = Driver(driverH: GDALGetDatasetDriver(datasetH))
        }
    }
    
    deinit {
        GDALClose(datasetH)
    }
    
    private func flush() {
        GDALFlushCache(datasetH)
    }
    
    func createCopy(with driver: Driver) {
        
    }
}

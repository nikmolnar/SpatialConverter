import AppKit

class ConvertViewController: NSViewController {
    @IBOutlet weak var datasetFileLabel: NSTextField!
    @IBOutlet weak var driverLabel: NSTextField!
    @IBOutlet weak var driverPopup: NSPopUpButton!
    @IBOutlet weak var outputFileButton: NSButton!
    @IBOutlet weak var outputFileLabel: NSTextField!
    @IBOutlet weak var convertButton: NSButton!
    @IBOutlet var fileDestinationView: FileDragDestinationView!
    
    var _dataset: Dataset?
    
    var dataset: Dataset? {
        get {
            return _dataset
        }
        set(dataset) {
            _dataset = dataset
            reset()
        }
    }
    
    private func reset() {
        datasetFileLabel.stringValue = dataset?.path ?? ""
        driverLabel.stringValue = dataset?.driver.longName ?? ""
        // Select driver
        outputFileLabel.stringValue = "No file selected"
        convertButton.isEnabled = false
    }
}

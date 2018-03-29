import Cocoa
import GDAL

class BaseViewController: NSViewController {
    @IBOutlet weak var dataPopup: NSPopUpButton!
    @IBOutlet weak var containerView: NSView!
    
    var fileDestinationController: NSViewController?
    var convertViewController: ConvertViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(GDAL.version)
        GDAL.Init()
        
        fileDestinationController = storyboard!.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier("fileDestinationController")
        ) as? NSViewController
        addChildViewController(fileDestinationController!)
        
        convertViewController = storyboard!.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier("convertViewController")
        ) as? ConvertViewController
        addChildViewController(convertViewController!)
        
        showFileDestinationView()
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
    
    func showFileDestinationView() {
        let dragView = fileDestinationController!.view as! FileDragDestinationView
        dragView.delegate = self
        
        if containerView.subviews.isEmpty {
            containerView.addSubview(dragView)
        }
        else if (containerView.subviews.first != dragView) {
            containerView.replaceSubview(containerView.subviews.first!, with: dragView)
        }
        
        self.containerView.frame = dragView.frame
        self.view.window?.layoutIfNeeded()
    }
    
    func showConvertView(with dataset: Dataset?) {
        let dragView = convertViewController!.view as! FileDragDestinationView
        dragView.delegate = self
        
        if containerView.subviews.isEmpty {
            containerView.addSubview(dragView)
        }
        else if (containerView.subviews.first != dragView) {
            containerView.replaceSubview(containerView.subviews.first!, with: dragView)
        }

        NSLayoutConstraint(
            item: containerView, attribute: .height, relatedBy: .equal, toItem: dragView, attribute: .height,
            multiplier: 1.0, constant: 0.0
        ).isActive = true
        NSLayoutConstraint(
            item: containerView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: dragView, attribute: .width,
            multiplier: 1.0, constant: 0.0
        ).isActive = true

        convertViewController!.dataset = dataset
    }
    
    func loadDatasetFromFile(_ url: URL) {
        Dataset.open(url) {
            datasetOrNil in
            if let dataset = datasetOrNil {
                self.showConvertView(with: dataset)
            }
            else {
                let alert = NSAlert()
                alert.alertStyle = .critical
                alert.messageText = "Could not open file."
                alert.informativeText = String(cString:CPLGetLastErrorMsg())
                alert.runModal()
            }
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

extension BaseViewController: FileDragDestinationDelegate {
    func didReceiveDrag(_ url: URL) {
        loadDatasetFromFile(url)
    }
}


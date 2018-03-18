import Cocoa

protocol FileDragDestinationDelegate {
    func didReceiveDrag(_ url: URL)
}

class FileDragDestinationView: NSView {
    var delegate: FileDragDestinationDelegate?
    
    var isReceivingDrag = false {
        didSet {
            needsDisplay = true
        }
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        registerForDraggedTypes([NSPasteboard.PasteboardType(kUTTypeFileURL as String)])
    }
    
    func canAcceptDrag(forInfo: NSDraggingInfo) -> Bool {
        let pasteBoard = forInfo.draggingPasteboard()
        return pasteBoard.canReadObject(forClasses: [NSURL.self], options: nil)
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let accept = canAcceptDrag(forInfo: sender)
        isReceivingDrag = accept
        return accept ? .copy : NSDragOperation()
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return canAcceptDrag(forInfo: sender)
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        isReceivingDrag = false
        
        let pasteboard = sender.draggingPasteboard()
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL], urls.count > 0 {
            delegate?.didReceiveDrag(urls[0])
            return true
        }
        return false
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if isReceivingDrag {
            NSColor.selectedControlColor.set()
            
            let path = NSBezierPath(rect: bounds)
            path.lineWidth = 10
            path.stroke()
        }
    }
}

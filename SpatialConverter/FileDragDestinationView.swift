import Cocoa

class FileDragDestinationView: NSView {
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
    
    override func draw(_ dirtyRect: NSRect) {
        if isReceivingDrag {
            NSColor.selectedControlColor.set()
            
            let path = NSBezierPath(rect: bounds)
            path.lineWidth = 10
            path.stroke()
        }
    }
}

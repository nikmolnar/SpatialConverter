import AppKit

class CollapsibleList: NSView {
    var stack: NSStackView
    var button: NSButton
    var labelField: NSTextField
    var listStack: NSStackView
    var _list: [String] = []
    var _expanded = false
    var target: Any? = nil
    var action: Selector? = nil
    
    var label: String {
        get {
            return labelField.stringValue
        }
        set {
           labelField.stringValue = label
        }
    }
    
    var expanded: Bool {
        get {
            return _expanded
        }
        set {
            _expanded = newValue
            
            if _expanded {
                button.state = .on
                stack.addView(listStack, in: .leading)
            }
            else {
                button.state = .off
                stack.removeView(listStack)
            }
        }
    }
    
    var list: [String] {
        get {
            return _list
        }
        set {
            _list = newValue
            var views: [NSTextField] = []
            for item in list {
                let label = NSTextField(string: item)
                label.isBezeled = false
                label.isEditable = false
                label.drawsBackground = false
                views.append(label)
            }
            listStack.setViews(views, in: .leading)
        }
    }
    
    init(label: String? = nil) {
        button = NSButton()
        button.bezelStyle = .disclosure
        button.setButtonType(.onOff)
        button.title = ""
        labelField = NSTextField(string: label ?? "")
        labelField.isBezeled = false
        labelField.isEditable = false
        labelField.drawsBackground = false
        listStack = NSStackView(views: [])
        listStack.orientation = .vertical
        
        let labelStack = NSStackView(views: [button, labelField])
        labelStack.orientation = .horizontal
        
        stack = NSStackView(views: [labelStack, listStack])
        stack.orientation = .vertical
        stack.setClippingResistancePriority(.defaultHigh, for: .vertical)
        stack.setVisibilityPriority(.detachOnlyIfNecessary, for: listStack)
        
        super.init(frame: NSRect(x: 0, y: 0, width: 0, height: 0))
        
        addSubview(stack)
        stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        button.target = self
        button.action = #selector(CollapsibleList.handleClick)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleClick() {
        if let action = action {
            NSApplication.shared.sendAction(action, to: target, from: self)
        }
    }
}

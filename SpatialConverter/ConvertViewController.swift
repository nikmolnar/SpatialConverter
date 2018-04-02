import AppKit

struct DatasetInfoItem {
    let label: String
    let value: String
    let list: [String]
}

class ConvertViewController: NSViewController {
    @IBOutlet var fileDestinationView: FileDragDestinationView!
    @IBOutlet weak var tableView: NSTableView!
    
    var datasetInfo: [DatasetInfoItem] = []
    var _dataset: Dataset?
    var rowHeights: [Int: CGFloat] = [:]
    
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
        datasetInfo = []
        
        if let dataset = dataset {
            if dataset.type == .File {
                datasetInfo.append(DatasetInfoItem(label: "File", value: dataset.path!, list: []))
            }
            else {
                datasetInfo.append(DatasetInfoItem(label: "Database", value: dataset.database!.name, list: []))
            }
            
            datasetInfo.append(DatasetInfoItem(label: "Driver", value: dataset.driver.longName, list: []))
            datasetInfo.append(DatasetInfoItem(label: "Layer", value: "Todo...", list: []))
            datasetInfo.append(DatasetInfoItem(label: "Test", value: "Some items...", list: ["One", "Two"]))
        }
        
        tableView.reloadData()
        tableView.tableColumns[0].width = 10
    }
    
    override func viewDidLoad() {
        tableView!.delegate = self
        tableView!.dataSource = self
    }
}

extension ConvertViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return datasetInfo.count
    }
}

extension ConvertViewController: NSTableViewDelegate {
    @objc func collapseAction(_ sender: Any?) {
        if let sender = sender as? CollapsibleList {
            let row = tableView.row(for: sender)
            
            sender.expanded = !sender.expanded
            rowHeights[row] = sender.fittingSize.height
            tableView.noteHeightOfRows(withIndexesChanged: IndexSet(integer: row))
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let infoItem = datasetInfo[row]
        
        if tableColumn == tableView.tableColumns[0] {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "LabelCellID")
            var cell = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTextField
            
            if cell == nil {
                cell = NSTextField(string: "")
            }
            
            if let cell = cell {
                cell.identifier = cellIdentifier
                cell.stringValue = infoItem.label + ": "
                cell.drawsBackground = false
                cell.isBezeled = false
                cell.isEditable = false
                cell.sizeToFit()
                tableColumn!.width = max(tableColumn!.width, cell.frame.width)
            }
            
            return cell
        }
        else if (tableColumn == tableView.tableColumns[1]) {
            if infoItem.list.isEmpty {
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "SingleValueCellID")
                var cell = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTextField
                
                if cell == nil {
                    cell = NSTextField(frame: NSRect(x: 0, y: 0, width: 0, height: 0))
                }
                
                if let cell = cell {
                    cell.identifier = cellIdentifier
                    cell.stringValue = infoItem.value
                    cell.drawsBackground = false
                    cell.isBezeled = false
                    cell.isEditable = false
                }
                
                return cell
            }
            else {
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ListValueCellID")
                var cell = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? CollapsibleList
                
                if cell == nil {
                    cell = CollapsibleList(label: infoItem.value)
                    cell!.target = self
                    cell!.action = #selector(collapseAction)
                }
                
                if let cell = cell {
                    cell.identifier = cellIdentifier
                    cell.label = infoItem.value
                    cell.list = infoItem.list
                    cell.expanded = false
                    rowHeights[row] = cell.fittingSize.height
                    tableView.noteHeightOfRows(withIndexesChanged: IndexSet(integer: row))
                }
                
                return cell
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if let height = rowHeights[row], height > 0 {
            return height
        }
        else {
            return tableView.rowHeight
        }
    }
}

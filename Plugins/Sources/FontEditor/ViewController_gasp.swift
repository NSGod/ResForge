//
//  ViewController_gasp.swift
//  FontEditor
//
//  Created by Mark Douma on 1/30/2026.
//

import Cocoa
import CoreFont

final class ViewController_gasp: FontTableViewController, NSTableViewDelegate {
    @IBOutlet weak var tableView:           NSTableView!
    @IBOutlet var rangesController:         NSArrayController!

    var table:      FontTable_gasp

    required init?(with fontTable: FontTable) {
        table = fontTable as! FontTable_gasp
        super.init(with: table)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var representedObject: Any? {
        didSet {
            self.table = self.representedObject as! FontTable_gasp
        }
    }

    override func prepareToSave() throws {
        NSLog("\(type(of: self)).\(#function)")
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn else { return nil }
        let identifier = tableColumn.identifier
        let view = tableView.makeView(withIdentifier: identifier, owner: self)
        if identifier.rawValue == "maxPPEM" {
            return view
        } else {
            let cellView: BitfieldTableCellView = view as! BitfieldTableCellView
            let ranges = rangesController.arrangedObjects as! [FontTable_gasp.Range]
            let range = ranges[row]
            cellView.bitfieldControl.objectValue = range.objcBehavior
            cellView.bitfieldControl.enabledMask = Int(table.version == .version0 ?
                                                       FontTable_gasp.Range.Behavior.version0Mask.rawValue :
                                                        FontTable_gasp.Range.Behavior.version1Mask.rawValue)
            cellView.bitfieldControl.tag = row
            return cellView
        }
    }

    @IBAction func changeBehavior(_ sender: Any) {
        let sender = sender as! NSButton
        let row = (sender.superview! as! BitfieldControl).tag
        let range = (rangesController.arrangedObjects as! [FontTable_gasp.Range])[row]
        if sender.state == .on {
            range.objcBehavior = range.objcBehavior | UInt16(sender.tag)
        } else {
            range.objcBehavior = range.objcBehavior & ~UInt16(sender.tag)
        }
    }

    @IBAction func setVersion(_ sender: Any) {
        tableView.reloadData()
    }
}

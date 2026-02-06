//
//  ViewController_head.swift
//  FontEditor
//
//  Created by Mark Douma on 1/19/2026.
//

import Cocoa
import CoreFont

final class ViewController_head: FontTableViewController {
    @IBOutlet weak var flagsControl:        BitfieldControl!
    @IBOutlet weak var macStyleControl:     BitfieldControl!

    var table:                              FontTable_head

    required init?(with fontTable: FontTable) {
        self.table = fontTable as! FontTable_head
        super.init(with: fontTable)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    deinit {
        flagsControl.unbind(NSBindingName("objectValue"))
        macStyleControl.unbind(NSBindingName("objectValue"))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        flagsControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "representedObject.objcFlags")
        macStyleControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "representedObject.objcMacStyle")
    }

    override var representedObject: Any? {
        didSet {
            self.table = self.representedObject as! FontTable_head
        }
    }

    @IBAction func changeFlags(_ sender: Any) {
        let checkbox = sender as! NSButton
        
        self.view.window?.windowController?.setDocumentEdited(true)
    }

    @IBAction func changeMacStyle(_ sender: Any) {

    }
}

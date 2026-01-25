//
//  ViewController_head.swift
//  FontEditor
//
//  Created by Mark Douma on 1/19/2026.
//

import Cocoa
import CoreFont

final public class ViewController_head: FontTableViewController {
    @IBOutlet weak var flagsControl:        BitfieldControl!
    @IBOutlet weak var macStyleControl:     BitfieldControl!

    var table:                              FontTable_head

    required init?(with fontTable: FontTable) {
        self.table = fontTable as! FontTable_head
        super.init(with: fontTable)
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        flagsControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "representedObject.objcFlags")
        macStyleControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "representedObject.objcMacStyle")
    }
    
    @IBAction func changeFlags(_ sender: Any) {

    }

    @IBAction func changeMacStyle(_ sender: Any) {

    }

}

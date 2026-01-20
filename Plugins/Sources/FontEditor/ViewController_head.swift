//
//  ViewController_head.swift
//  FontEditor
//
//  Created by Mark Douma on 1/19/2026.
//

import Cocoa
import CoreFont

final public class ViewController_head: FontTableViewController {

    var fontTable:      FontTable_head

    required init?(with fontTable: FontTable) {
        self.fontTable = fontTable as! FontTable_head
        super.init(with: fontTable)
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

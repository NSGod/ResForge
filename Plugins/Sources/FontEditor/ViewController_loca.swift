//
//  ViewController_loca.swift
//  FontEditor
//
//  Created by Mark Douma on 3/21/2026.
//

import Cocoa
import CoreFont

final class ViewController_loca: FontTableViewController {
    var table:      FontTable_loca

    required init?(with fontTable: FontTable) {
        table = fontTable as! FontTable_loca
        super.init(with: fontTable)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
            self.table = self.representedObject as! FontTable_loca
        }
    }
}

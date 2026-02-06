//
//  ViewController_hmtx.swift
//  FontEditor
//
//  Created by Mark Douma on 1/26/2026.
//

import Cocoa
import CoreFont

final class ViewController_hmtx: FontTableViewController {
    var table:      FontTable_hmtx

    required init?(with fontTable: FontTable) {
        table = fontTable as! FontTable_hmtx
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
            self.table = self.representedObject as! FontTable_hmtx
        }
    }
}

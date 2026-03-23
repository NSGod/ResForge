//
//  ViewController_cvt.swift
//  FontEditor
//
//  Created by Mark Douma on 3/23/2026.
//

import Cocoa
import CoreFont

final class ViewController_cvt: FontTableViewController {
    var table:          FontTable_cvt

    required init?(with fontTable: FontTable) {
        table = fontTable as! FontTable_cvt
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
            self.table = self.representedObject as! FontTable_cvt
        }
    }

    override func prepareToSave() throws {
        NSLog("\(type(of: self)).\(#function)")
    }
}

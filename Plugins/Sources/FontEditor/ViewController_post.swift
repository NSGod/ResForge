//
//  ViewController_post.swift
//  FontEditor
//
//  Created by Mark Douma on 1/22/2026.
//

import Cocoa
import CoreFont

final class ViewController_post: FontTableViewController {
    var table:                FontTable_post

    required init?(with fontTable: FontTable) {
        self.table = fontTable as! FontTable_post
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
            self.table = self.representedObject as! FontTable_post
        }
    }
}

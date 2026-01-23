//
//  ViewController_post.swift
//  FontEditor
//
//  Created by Mark Douma on 1/22/2026.
//

import Cocoa
import CoreFont

final public class ViewController_post: FontTableViewController {

    @objc public var table:                FontTable_post

    required init?(with fontTable: FontTable) {
        self.table = fontTable as! FontTable_post
        super.init(with: fontTable)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

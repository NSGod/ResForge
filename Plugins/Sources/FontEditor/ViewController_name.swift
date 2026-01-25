//
//  ViewController_name.swift
//  FontEditor
//
//  Created by Mark Douma on 1/25/2026.
//

import Cocoa
import CoreFont

final public class ViewController_name: FontTableViewController {
    var table:    FontTable_name

    required init?(with fontTable: FontTable) {
        table = fontTable as! FontTable_name
        super.init(with: fontTable)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
}

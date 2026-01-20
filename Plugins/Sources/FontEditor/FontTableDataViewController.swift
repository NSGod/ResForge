//
//  FontTableDataViewController.swift
//  Plugins
//
//  Created by Mark Douma on 1/19/2026.
//

import Cocoa
import CoreFont

final public class FontTableDataViewController: FontTableViewController {

    required init?(with fontTable: FontTable) {
        super.init(with: fontTable)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

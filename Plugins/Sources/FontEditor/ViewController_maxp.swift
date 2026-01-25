//
//  ViewController_maxp.swift
//  FontEditor
//
//  Created by Mark Douma on 1/21/2026.
//

import Cocoa
import CoreFont

final public class ViewController_maxp: FontTableViewController {
	@IBOutlet weak var version1View:    NSView!

	var table:                          FontTable_maxp

	required init?(with fontTable: FontTable) {
		self.table = fontTable as! FontTable_maxp
		super.init(with: fontTable)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    func updateUI() {
        for control: NSControl in version1View.subviews as? [NSControl] ?? [] {
            control.isEnabled = table.version == .version1_0
        }
    }

    @IBAction func changeVersion(_ sender: Any) {
        updateUI()
    }
}

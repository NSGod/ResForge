//
//  ViewController_glyf.swift
//  FontEditor
//
//  Created by Mark Douma on 4/11/2026.
//

import Cocoa
import CoreFont

final class ViewController_glyf: FontTableViewController {
    @IBOutlet weak var box:         NSBox!

    var glyphCollectionViewController: UIGlyphCollectionViewController!

    var table:          FontTable_glyf

    required init?(with fontTable: FontTable) {
        table = fontTable as! FontTable_glyf
        super.init(with: table)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        glyphCollectionViewController = UIGlyphCollectionViewController(glyphsProvider: table.fontFile, itemSizeAutosaveName: "glyfViewController")
        box.contentView = glyphCollectionViewController.view
    }
}

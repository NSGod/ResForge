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

    @IBAction func export(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.prompt = NSLocalizedString("Choose", comment: "")
        panel.message = NSLocalizedString("Choose a folder to export glyphs to", comment: "")
        panel.isExtensionHidden = false
        panel.beginSheetModal(for: view.window!) { [self] (result) in
            if result == .OK {
                let feGlyphs = glyphCollectionViewController.glyphs
                let glyphView = UIGlyphView(frame: NSMakeRect(0, 0, 2048, 2048))
                for feGlyph in feGlyphs {
                    glyphView.glyph = feGlyph.glyph
                    autoreleasepool {
                        if let bitmapRep = glyphView.bitmapImageRepForCachingDisplay(in: glyphView.bounds) {
                            glyphView.cacheDisplay(in: glyphView.bounds, to: bitmapRep)
                            if let data = bitmapRep.representation(using: .png, properties: [:]) {
                                let url = panel.url!.appendingPathComponent(feGlyph.glyphName).appendingPathExtension("png").assuringUniqueFilename()
                                do {
                                    try data.write(to: url)
                                } catch {
                                    NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

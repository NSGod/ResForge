//
//  ViewController_glyf.swift
//  FontEditor
//
//  Created by Mark Douma on 4/11/2026.
//

import Cocoa
import CoreFont

final class ViewController_glyf: FontTableViewController {
    @IBOutlet weak var box:                 NSBox!
    @IBOutlet weak var statusField:         NSTextField!
    @IBOutlet weak var progressIndicator:   NSProgressIndicator!
    @IBOutlet weak var exportButton:        NSButton!

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
        panel.prompt = NSLocalizedString("Export", comment: "")
        panel.message = NSLocalizedString("Choose a folder to export the glyphs to", comment: "")
        panel.isExtensionHidden = false
        panel.beginSheetModal(for: view.window!) { [self] (result) in
            if result == .OK {
                exportImages(to: panel.url!)
            }
        }
    }

    func exportImages(to url: URL) {
        let feGlyphs = self.glyphCollectionViewController.glyphs
        let glyphView = UIGlyphView(frame: NSMakeRect(0, 0, 2048, 2048))
        DispatchQueue.global().async {
            var i = 0
            for feGlyph in feGlyphs {
                DispatchQueue.main.async {
                    if i == 0 {
                        self.progressIndicator.maxValue = Double(feGlyphs.count)
                        self.progressIndicator.startAnimation(nil)
                    }
                    self.statusField.stringValue = "\(i + 1) of \(feGlyphs.count)"
                    self.progressIndicator.doubleValue = Double(i + 1)
                    if i == feGlyphs.count - 1 {
                        self.progressIndicator.stopAnimation(nil)
                        self.statusField.stringValue = ""
                    }
                }
                DispatchQueue.main.sync { [weak self] in
                    glyphView.glyph = feGlyph.glyph
                    autoreleasepool {
                        if let bitmapRep = glyphView.bitmapImageRepForCachingDisplay(in: glyphView.bounds) {
                            glyphView.cacheDisplay(in: glyphView.bounds, to: bitmapRep)
                            DispatchQueue.global().async {
                                autoreleasepool {
                                    if let srgbRep = bitmapRep.retagging(with: .sRGB) {
                                        if let data = srgbRep.representation(using: .png, properties: [:]) {
                                            let url = url.appendingPathComponent(feGlyph.glyphName).appendingPathExtension("png").assuringUniqueFilename()
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
                i += 1
            }
        }
    }

}

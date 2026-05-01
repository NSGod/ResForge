//
//  FontImporterController.swift
//  FontEditor
//
//  Created by Mark Douma on 4/16/2026.
//

import Cocoa
import RFSupport
import CoreFont

final class FontImporterController: NSWindowController, NSWindowDelegate {
    @IBOutlet weak var sizesField:  NSTextField!

    @objc dynamic var fontFile:     OTFFontFile?
    @objc dynamic var url:          URL?
    var data:                       Data?

    @objc dynamic var createFOND:    Bool = true
    @objc dynamic var createNFNT:    Bool = true
    @objc dynamic var sizes:         [Int] = []

    private weak var fontEditor:    FontEditor!
    private let manager:            RFEditorManager
    private var importingFont:      Bool = false

    // FIXME: limit encoding popup button menu to only those encoding MacScriptIDs found in cmap table
    // FIXME: try to find an existing FOND and present that/give the option to use that one instead of creating new one

    deinit {
        NSLog("\(type(of: self)).\(#function)")
    }

    override var windowNibPath: String? {
        return FontEditor.bundle.url(forResource: windowNibName, withExtension: "nib")?.path
    }

    override var windowNibName: NSNib.Name? {
        return "FontImporterController"
    }

    init(fontEditor: FontEditor, manager: RFEditorManager) {
        NSLog("\(type(of: self)).\(#function)")
        UserDefaults.standard.register(defaults: [FontCreationOptions.createFONDKey: true,
                                                  FontCreationOptions.createNFNTKey: true,
                                                  FontCreationOptions.sizesKey: [9, 10, 11, 12, 16]])
        self.fontEditor = fontEditor
        self.manager = manager
        createFOND = UserDefaults.standard.bool(forKey: FontCreationOptions.createFONDKey)
        createNFNT = UserDefaults.standard.bool(forKey: FontCreationOptions.createNFNTKey)
        sizes = UserDefaults.standard.array(forKey: FontCreationOptions.sizesKey) as! [Int]
        super.init(window: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func windowDidLoad() {
        NSLog("\(type(of: self)).\(#function)")
        super.windowDidLoad()
    }

    override func showWindow(_ sender: Any?) {
        NSLog("\(type(of: self)).\(#function)")
        super.showWindow(sender)
    }

    func windowWillClose(_ notification: Notification) {
        NSLog("\(type(of: self)).\(#function) \(notification)")
        if !importingFont {
            /// If our window is closing, and we're not importing a font, then the
            /// user has canceled the operation. Close the `FontEditor`'s window so that
            /// we (`FontEditor` & `FontImporterController`) will both be deallocated,
            /// and the user returned to the document window.
            fontEditor.window?.close()
            return
        }
        UserDefaults.standard.set(createFOND, forKey: FontCreationOptions.createFONDKey)
        UserDefaults.standard.set(createNFNT, forKey: FontCreationOptions.createNFNTKey)
        UserDefaults.standard.set(sizes, forKey: FontCreationOptions.sizesKey)
    }

    @IBAction func chooseFile(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")
        let panel = NSOpenPanel()
        panel.prompt = NSLocalizedString("Choose", comment: "")
        panel.allowedContentTypes = [.ttfFont]
        panel.beginSheetModal(for: window!) { [self] returnCode in
            if returnCode == .OK, let url = panel.url {
                self.url = url
                do {
                    fontFile = try OTFFontFile(contentsOf: url)
                    data = try Data(contentsOf: url)
                    // FIXME: update the encoding popup button to choose the default encoding based on 'cmap' entries
                } catch {
                    NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
                    self.presentError(error)
                }
            }
        }
    }

    @IBAction func importFont(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")
        importingFont = true
        let options = FontCreationOptions(fontFile: fontFile!, editorManager: manager, sfnt: fontEditor.resource, createFOND: createFOND, encoding: .macRoman, createNFNT: createNFNT)
        fontEditor.importFont(with: data!, options: options)
    }
}

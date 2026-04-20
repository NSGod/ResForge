//
//  FontImporterController.swift
//  FontEditor
//
//  Created by Mark Douma on 4/16/2026.
//

import Cocoa
import RFSupport
import CoreFont

class FontImporterController: NSWindowController, NSWindowDelegate {
    @IBOutlet weak var sizesField:  NSTextField!

    @objc dynamic var fontFile:     OTFFontFile?
    @objc dynamic var url:          URL?

    @objc dynamic var createFOND:    Bool = true
    @objc dynamic var createNFNT:    Bool = true
    @objc dynamic var sizes:         [Int] = []

    private weak var fontEditor:    FontEditor!
    private var importingFont:      Bool = false
    private var listFormatter:      ListFormatter!

    deinit {
        NSLog("\(type(of: self)).\(#function)")
    }

    override var windowNibPath: String? {
        return FontEditor.bundle.url(forResource: windowNibName, withExtension: "nib")?.path
    }

    override var windowNibName: NSNib.Name? {
        return "FontImporterController"
    }

    init(fontEditor: FontEditor) {
        NSLog("\(type(of: self)).\(#function)")
        UserDefaults.standard.register(defaults: [FontCreationOptions.createFONDKey: true,
                                                  FontCreationOptions.createNFNTKey: true,
                                                  FontCreationOptions.sizesKey: [9, 10, 11, 12, 16]])
        self.fontEditor = fontEditor
        createFOND = UserDefaults.standard.bool(forKey: FontCreationOptions.createFONDKey)
        createNFNT = UserDefaults.standard.bool(forKey: FontCreationOptions.createNFNTKey)
        sizes = UserDefaults.standard.array(forKey: FontCreationOptions.sizesKey) as! [Int]
        listFormatter = .init()
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .decimal
        numFormatter.minimum = 0
        numFormatter.maximum = 100
        listFormatter.itemFormatter = numFormatter
        super.init(window: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func windowDidLoad() {
        NSLog("\(type(of: self)).\(#function)")
        sizesField.formatter = listFormatter
        super.windowDidLoad()
    }

    override func showWindow(_ sender: Any?) {
        NSLog("\(type(of: self)).\(#function)")
        super.showWindow(sender)
    }

    func windowWillClose(_ notification: Notification) {
        NSLog("\(type(of: self)).\(#function) \(notification)")
        if !importingFont {
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
                    self.fontFile = try OTFFontFile(contentsOf: url)
                } catch {
                    NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
                    self.presentError(error)
                }
            }
        }
    }

    @IBAction func importFont(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")
        do {
            let data = try Data(contentsOf: url!)
            importingFont = true
            fontEditor.importFont(with: data)
        } catch {
            NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
        }
    }
}

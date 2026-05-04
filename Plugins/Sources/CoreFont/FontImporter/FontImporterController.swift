//
//  FontImporterController.swift
//  CoreFont
//
//  Created by Mark Douma on 4/16/2026.
//

import Cocoa
import RFSupport

public protocol FontImporterDelegate: AnyObject {
    var resource: Resource { get set }
    func importFont(with data: Data, options: FontCreationOptions)
}

public final class FontImporterController: NSWindowController, NSWindowDelegate {
    @IBOutlet weak var sizesField:  NSTextField!

    @objc dynamic public var fontFile:     OTFFontFile?
    @objc dynamic public var url:          URL?
    public var data:                       Data?

    public weak var delegate:              FontImporterDelegate?

    @objc dynamic public var createFOND:   Bool = true
    @objc dynamic public var createNFNT:   Bool = true
    @objc dynamic public var sizes:        [Int] = []

    private let manager:            RFEditorManager
    private var importingFont:      Bool = false

    // FIXME: limit encoding popup button menu to only those encoding MacScriptIDs found in cmap table
    // FIXME: try to find an existing FOND and present that/give the option to use that one instead of creating new one

    deinit {
        NSLog("\(type(of: self)).\(#function)")
    }

    public override var windowNibPath: String? {
        return Bundle.module.url(forResource: windowNibName, withExtension: "nib")?.path
    }

    public override var windowNibName: NSNib.Name? {
        return "FontImporterController"
    }

    public init(delegate: FontImporterDelegate, manager: RFEditorManager) {
        NSLog("\(type(of: self)).\(#function)")
        UserDefaults.standard.register(defaults: [FontCreationOptions.createFONDKey: true,
                                                  FontCreationOptions.createNFNTKey: true,
                                                  FontCreationOptions.sizesKey: [10, 11, 12]])
        self.delegate = delegate
        self.manager = manager
        createFOND = UserDefaults.standard.bool(forKey: FontCreationOptions.createFONDKey)
        createNFNT = UserDefaults.standard.bool(forKey: FontCreationOptions.createNFNTKey)
        sizes = UserDefaults.standard.array(forKey: FontCreationOptions.sizesKey) as! [Int]
        super.init(window: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func windowDidLoad() {
        NSLog("\(type(of: self)).\(#function)")
        super.windowDidLoad()
    }

    public override func showWindow(_ sender: Any?) {
        NSLog("\(type(of: self)).\(#function)")
        super.showWindow(sender)
    }

    public func windowWillClose(_ notification: Notification) {
        NSLog("\(type(of: self)).\(#function) \(notification)")
        if !importingFont {
            /// If our window is closing, and we're not importing a font, then the
            /// user has canceled the operation. Close the `delegate`'s window so that
            /// we (the delegate (`FontEditor` or `FONDEditor`) & `FontImporterController`) will
            /// both be deallocated, and the user returned to the document window.
            if let delegate = delegate as? NSWindowController {
                delegate.window?.close()
                return
            }
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
        if let delegate {
            let options = FontCreationOptions(fontFile: fontFile!, editorManager: manager, sfnt: delegate.resource, createFOND: createFOND, encoding: .macRoman, createNFNT: createNFNT)
            delegate.importFont(with: data!, options: options)
        }
    }
}

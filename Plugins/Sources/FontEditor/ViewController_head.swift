//
//  ViewController_head.swift
//  FontEditor
//
//  Created by Mark Douma on 1/19/2026.
//

import Cocoa
import CoreFont

final class ViewController_head: FontTableViewController, NSControlTextEditingDelegate {
    @IBOutlet weak var flagsControl:        BitfieldControl!
    @IBOutlet weak var macStyleControl:     BitfieldControl!

    var table:                              FontTable_head

    @objc dynamic var objcFlags:        UInt16 = 0
    @objc dynamic var objcMacStyle:     UInt16 = 0
    @objc dynamic var objcUnitsPerEm:   UInt16 = 0

    private static var tableContext = 1
    private static let tableKeyPaths = Set(["version", "fontRevision", "checksumAdjustment", "magicNumber",
                                            "created", "modified", "xMin", "yMin", "xMax", "yMax",
                                       "lowestRecPPEM", "fontDirectionHint", "indexToLocFormat", "glyphDataFormat"])
    private static let keyPaths = Set(["objcFlags", "objcUnitsPerEm", "objcMacStyle"])

    required init?(with fontTable: FontTable) {
        self.table = fontTable as! FontTable_head
        super.init(with: fontTable)
        objcFlags = table.flags.rawValue
        objcMacStyle = table.macStyle.rawValue
        objcUnitsPerEm = table.unitsPerEm.rawValue
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    deinit {
        flagsControl.unbind(NSBindingName("objectValue"))
        macStyleControl.unbind(NSBindingName("objectValue"))
        Self.tableKeyPaths.forEach { table.removeObserver(self, forKeyPath: $0, context: &Self.tableContext) }
        Self.keyPaths.forEach { removeObserver(self, forKeyPath: $0, context: nil) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        flagsControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "objcFlags")
        macStyleControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "objcMacStyle")
        Self.tableKeyPaths.forEach { table.addObserver(self, forKeyPath: $0, options: [.new, .old], context: &Self.tableContext) }
        Self.keyPaths.forEach { addObserver(self, forKeyPath: $0, options: [.new, .old], context: nil) }
    }

    override var representedObject: Any? {
        didSet {
            self.table = self.representedObject as! FontTable_head
        }
    }

    override func prepareToSave() throws {
        NSLog("\(type(of: self)).\(#function)")
        if let window = view.window {
            if !window.makeFirstResponder(nil) {
                NSLog("\(type(of: self)).\(#function) could not become first responder!")
            }
        }
        table.flags = FontTable_head.Flags(rawValue: objcFlags)
        table.macStyle = MacFontStyle(rawValue: objcMacStyle)
        table.unitsPerEm = UnitsPerEm(rawValue: objcUnitsPerEm)
    }

    // MARK: - <NSControlTextEditingDelegate>
    public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if fieldEditor.string.isEmpty { return false }
        return true
    }

    // MARK: -
    @IBAction func changeFlags(_ sender: Any) {
        let sender = sender as! NSButton
        if sender.state == .on {
            objcFlags |= UInt16(sender.tag)
        } else {
            objcFlags &= ~UInt16(sender.tag)
        }
    }

    @IBAction func changeMacStyle(_ sender: Any) {
        let sender = sender as! NSButton
        if sender.state == .on {
            objcMacStyle |= UInt16(sender.tag)
        } else {
            objcMacStyle &= ~UInt16(sender.tag)
        }
    }

    @IBAction func now(_ sender: Any) {
        let tag = (sender as! NSButton).tag
        if tag == 0 {
            table.created = Date().secondsSince1904
        } else {
            table.modified = Date().secondsSince1904
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
//        NSLog("\(type(of: self)).\(#function) keyPath: \(keyPath)")
        if !Self.tableKeyPaths.contains(keyPath) && !Self.keyPaths.contains(keyPath) {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        if context == &Self.tableContext {
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.setValue(change![.oldKey], forKey: keyPath)
            })
        } else {
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.setValue(change![.oldKey], forKey: keyPath)
            })
        }
        view.window?.isDocumentEdited = true
        if keyPath == "version" {
            undoManager?.setActionName(NSLocalizedString("Change Version", comment: ""))
        } else if keyPath == "fontRevision" {
            undoManager?.setActionName(NSLocalizedString("Change Font Revision", comment: ""))
        } else if keyPath == "checkSumAdjustment" {
            undoManager?.setActionName(NSLocalizedString("Change Checksum Adjustment", comment: ""))
        } else if keyPath == "magicNumber" {
            undoManager?.setActionName(NSLocalizedString("Change Magic Number", comment: ""))
        } else if keyPath == "objcFlags" {
            undoManager?.setActionName(NSLocalizedString("Change Flags", comment: ""))
        } else if keyPath == "objcUnitsPerEm" {
            undoManager?.setActionName(NSLocalizedString("Change Units Per Em", comment: ""))
        } else if keyPath == "created" {
            undoManager?.setActionName(NSLocalizedString("Change Created Date", comment: ""))
        } else if keyPath == "modified" {
            undoManager?.setActionName(NSLocalizedString("Change Modified Date", comment: ""))
        } else if keyPath == "xMin" {
            undoManager?.setActionName(NSLocalizedString("Change x-Min", comment: ""))
        } else if keyPath == "yMin" {
            undoManager?.setActionName(NSLocalizedString("Change y-Min", comment: ""))
        } else if keyPath == "xMax" {
            undoManager?.setActionName(NSLocalizedString("Change x-Max", comment: ""))
        } else if keyPath == "yMax" {
            undoManager?.setActionName(NSLocalizedString("Change y-Max", comment: ""))
        } else if keyPath == "objcMacStyle" {
            undoManager?.setActionName(NSLocalizedString("Change Mac Style", comment: ""))
        } else if keyPath == "lowestRecPPEM" {
            undoManager?.setActionName(NSLocalizedString("Change Lowest Recommended Pixels Per Em", comment: ""))
        } else if keyPath == "fontDirectionHint" {
            undoManager?.setActionName(NSLocalizedString("Change Font Direction Hint", comment: ""))
        } else if keyPath == "indexToLocFormat" {
            undoManager?.setActionName(NSLocalizedString("Change Index to Location Format", comment: ""))
        } else if keyPath == "glyphDataFormat" {
            undoManager?.setActionName(NSLocalizedString("Change Glyph Data Format", comment: ""))
        }
    }
}

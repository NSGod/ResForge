//
//  ViewController_head.swift
//  FontEditor
//
//  Created by Mark Douma on 1/19/2026.
//

import Cocoa
import CoreFont

final class ViewController_head: FontTableViewController {
    @IBOutlet weak var flagsControl:        BitfieldControl!
    @IBOutlet weak var macStyleControl:     BitfieldControl!

    var table:                              FontTable_head

    @objc var objcFlags:        UInt16 = 0
    @objc var objcMacStyle:     UInt16 = 0
    @objc var objcUnitsPerEm:   UInt16 = 0

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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        flagsControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "objcFlags")
        macStyleControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "objcMacStyle")

        table.addObserver(self, forKeyPath: "version", options: [.new, .old], context: &table.version)
        table.addObserver(self, forKeyPath: "fontRevision", options: [.new, .old], context: &table.fontRevision)
        table.addObserver(self, forKeyPath: "checksumAdjustment", options: [.new, .old], context: &table.checkSumAdjustment)
        table.addObserver(self, forKeyPath: "magicNumber", options: [.new, .old], context: &table.magicNumber)
        addObserver(self, forKeyPath: "objcFlags", options: [.new, .old], context: &objcFlags)
        addObserver(self, forKeyPath: "objcUnitsPerEm", options: [.new, .old], context: &objcUnitsPerEm)
        table.addObserver(self, forKeyPath: "created", options: [.new, .old], context: &table.created)
        table.addObserver(self, forKeyPath: "modified", options: [.new, .old], context: &table.modified)
        table.addObserver(self, forKeyPath: "xMin", options: [.new, .old], context: &table.xMin)
        table.addObserver(self, forKeyPath: "yMin", options: [.new, .old], context: &table.yMin)
        table.addObserver(self, forKeyPath: "xMax", options: [.new, .old], context: &table.xMax)
        table.addObserver(self, forKeyPath: "yMax", options: [.new, .old], context: &table.yMax)
        addObserver(self, forKeyPath: "objcMacStyle", options: [.new, .old], context: &objcMacStyle)
        table.addObserver(self, forKeyPath: "lowestRecPPEM", options: [.new, .old], context: &table.lowestRecPPEM)
        table.addObserver(self, forKeyPath: "fontDirectionHint", options: [.new, .old], context: &table.fontDirectionHint)
        table.addObserver(self, forKeyPath: "indexToLocFormat", options: [.new, .old], context: &table.indexToLocFormat)
        table.addObserver(self, forKeyPath: "glyphDataFormat", options: [.new, .old], context: &table.glyphDataFormat)
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

    @IBAction func changeFlags(_ sender: Any) {
        let sender = sender as! NSButton
        let flags = UInt16(sender.tag)
        self.willChangeValue(forKey: "objcFlags")
        if sender.state == .on {
            objcFlags |= flags
        } else {
            objcFlags &= ~flags
        }
        self.didChangeValue(forKey: "objcFlags")
    }

    @IBAction func changeMacStyle(_ sender: Any) {
        let sender = sender as! NSButton
        let macStyle = UInt16(sender.tag)
        self.willChangeValue(forKey: "objcMacStyle")
        if sender.state == .on {
            objcMacStyle |= macStyle
        } else {
            objcMacStyle &= ~macStyle
        }
        self.didChangeValue(forKey: "objcMacStyle")
    }

    @IBAction func now(_ sender: Any) {
        let tag = (sender as! NSButton).tag
        if tag == 0 {
            table.willChangeValue(forKey: "created")
            table.created = Date().secondsSince1904
            table.didChangeValue(forKey: "created")
        } else {
            table.willChangeValue(forKey: "modified")
            table.modified = Date().secondsSince1904
            table.didChangeValue(forKey: "modified")
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        NSLog("\(type(of: self)).\(#function) keyPath: \(String(describing: keyPath))")
        guard let context else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        if context == &table.version {
            undoManager?.setActionName(NSLocalizedString("Change Version", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "version")
                $0.table.version = FontTable_head.Version(rawValue: change![.oldKey] as! Int32)!
                $0.table.didChangeValue(forKey: "version")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.fontRevision {
            undoManager?.setActionName(NSLocalizedString("Change Font Revision", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "fontRevision")
                $0.table.fontRevision = change![.oldKey] as! Int32
                $0.table.didChangeValue(forKey: "fontRevision")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.checkSumAdjustment {
            undoManager?.setActionName(NSLocalizedString("Change Checksum Adjustment", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "checkSumAdjustment")
                $0.table.checkSumAdjustment = change![.oldKey] as! UInt32
                $0.table.didChangeValue(forKey: "checkSumAdjustment")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.magicNumber {
            undoManager?.setActionName(NSLocalizedString("Change Magic Number", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "magicNumber")
                $0.table.magicNumber = change![.oldKey] as! UInt32
                $0.table.didChangeValue(forKey: "magicNumber")
            })
            view.window?.isDocumentEdited = true
        } else if context == &objcFlags {
            undoManager?.setActionName(NSLocalizedString("Change Flags", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.willChangeValue(forKey: "objcFlags")
                $0.objcFlags = change![.oldKey] as! UInt16
                $0.didChangeValue(forKey: "objcFlags")
            })
            view.window?.isDocumentEdited = true
        } else if context == &objcUnitsPerEm {
            undoManager?.setActionName(NSLocalizedString("Change Units Per Em", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.willChangeValue(forKey: "objcUnitsPerEm")
                $0.objcUnitsPerEm = change![.oldKey] as! UInt16
                $0.didChangeValue(forKey: "objcUnitsPerEm")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.created {
            undoManager?.setActionName(NSLocalizedString("Change Created Date", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "created")
                $0.table.created = change![.oldKey] as! Int64
                $0.table.didChangeValue(forKey: "created")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.modified {
            undoManager?.setActionName(NSLocalizedString("Change Modified Date", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "modified")
                $0.table.modified = change![.oldKey] as! Int64
                $0.table.didChangeValue(forKey: "modified")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.xMin {
            undoManager?.setActionName(NSLocalizedString("Change x-Min", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "xMin")
                $0.table.xMin = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "xMin")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.yMin {
            undoManager?.setActionName(NSLocalizedString("Change y-Min", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "yMin")
                $0.table.yMin = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "yMin")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.xMax {
            undoManager?.setActionName(NSLocalizedString("Change x-Max", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "xMax")
                $0.table.xMax = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "xMax")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.yMax {
            undoManager?.setActionName(NSLocalizedString("Change y-Max", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "yMax")
                $0.table.yMax = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "yMax")
            })
            view.window?.isDocumentEdited = true
        } else if context == &objcMacStyle {
            undoManager?.setActionName(NSLocalizedString("Change Mac Style", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.willChangeValue(forKey: "objcMacStyle")
                $0.objcMacStyle = change![.oldKey] as! UInt16
                $0.didChangeValue(forKey: "objcMacStyle")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.lowestRecPPEM {
            undoManager?.setActionName(NSLocalizedString("Change Lowest Recommended Pixels Per Em", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "lowestRecPPEM")
                $0.table.lowestRecPPEM = change![.oldKey] as! UInt16
                $0.table.didChangeValue(forKey: "lowestRecPPEM")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.fontDirectionHint {
            undoManager?.setActionName(NSLocalizedString("Change Font Direction Hint", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "fontDirectionHint")
                $0.table.fontDirectionHint = FontTable_head.FontDirectionHint(rawValue: change![.oldKey] as! Int16)!
                $0.table.didChangeValue(forKey: "fontDirectionHint")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.indexToLocFormat {
            undoManager?.setActionName(NSLocalizedString("Change Index to Location Format", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "indexToLocFormat")
                $0.table.indexToLocFormat = FontTable_head.IndexToLocFormat(rawValue: change![.oldKey] as! Int16)!
                $0.table.didChangeValue(forKey: "indexToLocFormat")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.glyphDataFormat {
            undoManager?.setActionName(NSLocalizedString("Change Glyph Data Format", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "glyphDataFormat")
                $0.table.glyphDataFormat = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "glyphDataFormat")
            })
            view.window?.isDocumentEdited = true
        }
    }
}

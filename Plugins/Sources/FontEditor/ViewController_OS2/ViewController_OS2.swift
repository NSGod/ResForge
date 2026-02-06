//
//  ViewController_OS2.swift
//  FontEditor
//
//  Created by Mark Douma on 1/29/2026.
//

import Cocoa
import CoreFont
import RFSupport

final class ViewController_OS2: FontTableViewController {

    @IBOutlet weak var unicodeRangesTableView:  NSTableView!
    @IBOutlet weak var codeRangesTableView:     NSTableView!

    @IBOutlet var unicodeRangePopover:          NSPopover!
    @IBOutlet var codePageRangePopover:         NSPopover!

    @IBOutlet weak var fontTypeControl:         BitfieldControl!
    @IBOutlet weak var fontSelectionControl:    BitfieldControl!

    @IBOutlet weak var unicodeRangeButton:      NSButton!
    @IBOutlet weak var version1UnicodeView:     NSView!
    @IBOutlet weak var codePageView:            NSView!
    @IBOutlet weak var version2View:            NSView!
    @IBOutlet weak var version5View:            NSView!

    var table:  FontTable_OS2

    @objc var ulUnicodeRange1:  FontTable_OS2.UnicodeMask1.RawValue = 0 {
        didSet {
            undoManager?.setActionName(NSLocalizedString("Change Unicode Range", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.willChangeValue(forKey: "ulUnicodeRange1")
                $0.ulUnicodeRange1 = oldValue
                $0.didChangeValue(forKey: "ulUnicodeRange1")
                if #available(macOS 14.4, *) {
                    if let undoCount = $0.undoManager?.undoCount, undoCount == 0 {
                        $0.view.window?.isDocumentEdited = false
                    }
                }
            })
            view.window?.isDocumentEdited = true
            unicodeRangesTableView.reloadData()
        }
    }

    @objc var ulUnicodeRange2:  FontTable_OS2.UnicodeMask2.RawValue = 0 {
        didSet {
            undoManager?.setActionName(NSLocalizedString("Change Unicode Range", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.willChangeValue(forKey: "ulUnicodeRange2")
                $0.ulUnicodeRange2 = oldValue
                $0.didChangeValue(forKey: "ulUnicodeRange2")
                if #available(macOS 14.4, *) {
                    if let undoCount = $0.undoManager?.undoCount, undoCount == 0 {
                        $0.view.window?.isDocumentEdited = false
                    }
                }
            })
            view.window?.isDocumentEdited = true
            unicodeRangesTableView.reloadData()
        }
    }

    @objc var ulUnicodeRange3:  FontTable_OS2.UnicodeMask3.RawValue = 0 {
        didSet {
            undoManager?.setActionName(NSLocalizedString("Change Unicode Range", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.willChangeValue(forKey: "ulUnicodeRange3")
                $0.ulUnicodeRange3 = oldValue
                $0.didChangeValue(forKey: "ulUnicodeRange3")
            })
            view.window?.isDocumentEdited = true
            unicodeRangesTableView.reloadData()
        }
    }

    @objc var ulUnicodeRange4:  FontTable_OS2.UnicodeMask4.RawValue = 0 {
        didSet {
            undoManager?.setActionName(NSLocalizedString("Change Unicode Range", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.willChangeValue(forKey: "ulUnicodeRange4")
                $0.ulUnicodeRange4 = oldValue
                $0.didChangeValue(forKey: "ulUnicodeRange4")
            })
            view.window?.isDocumentEdited = true
            unicodeRangesTableView.reloadData()
        }
    }

    @objc var ulCodePageRange1:  UInt32  = 0 {
        didSet {
            undoManager?.setActionName(NSLocalizedString("Change Code Page Range", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.willChangeValue(forKey: "ulCodePageRange1")
                $0.ulCodePageRange1 = oldValue
                $0.didChangeValue(forKey: "ulCodePageRange1")
            })
            view.window?.isDocumentEdited = true
            codeRangesTableView.reloadData()
        }
    }

    @objc var ulCodePageRange2:  UInt32  = 0 {
        didSet {
            undoManager?.setActionName(NSLocalizedString("Change Code Page Range", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.willChangeValue(forKey: "ulCodePageRange2")
                $0.ulCodePageRange2 = oldValue
                $0.didChangeValue(forKey: "ulCodePageRange2")
            })
            view.window?.isDocumentEdited = true
            codeRangesTableView.reloadData()
        }
    }

    @objc var usWeightClass:    UInt16 = 0 {
        didSet {
            undoManager?.setActionName(NSLocalizedString("Change Weight", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.willChangeValue(forKey: "usWeightClass")
                $0.usWeightClass = oldValue
                $0.didChangeValue(forKey: "usWeightClass")
            })
            view.window?.isDocumentEdited = true
        }
    }

    @objc var fsType:           UInt16 = 0 {
        didSet {
            undoManager?.setActionName(NSLocalizedString("Change Font Type", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.willChangeValue(forKey: "fsType")
                $0.fsType = oldValue
                $0.didChangeValue(forKey: "fsType")
            })
            view.window?.isDocumentEdited = true
        }
    }

    @objc var fsSelection:      UInt16 = 0 {
        didSet {
            undoManager?.setActionName("Change Font Selection")
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.willChangeValue(forKey: "fsSelection")
                $0.fsSelection = oldValue
                $0.didChangeValue(forKey: "fsSelection")
            })
            view.window?.isDocumentEdited = true
        }
    }

    private var unicodeBlocksToNames:   [Int: String] = [:]
    private var codePageRangesToNames:  [Int: String] = [:]

    required init?(with fontTable: FontTable) {
        table = fontTable as! FontTable_OS2
        usWeightClass = table.usWeightClass.rawValue
        fsType = table.fsType.rawValue
        ulUnicodeRange1 = table.ulUnicodeRange1.rawValue
        ulUnicodeRange2 = table.ulUnicodeRange2.rawValue
        ulUnicodeRange3 = table.ulUnicodeRange3.rawValue
        ulUnicodeRange4 = table.ulUnicodeRange4.rawValue
        ulCodePageRange1 = table.ulCodePageRange1.rawValue
        ulCodePageRange2 = table.ulCodePageRange2.rawValue
        fsSelection = table.fsSelection.rawValue
        super.init(with: fontTable)
        do {
            let uBlocksToNames: [String: String] = try NSDictionary(contentsOf: Bundle.module.url(forResource: "MDUnicodeBlocksOS2", withExtension: "plist")!, error: ()) as! [String: String]
            for (key, value) in uBlocksToNames {
                unicodeBlocksToNames[Int(key)!] = value
            }
            let cPageRangesToNames: [String: String] = try NSDictionary(contentsOf: Bundle.module.url(forResource: "MDCodePageRangesOS2", withExtension: "plist")!, error: ()) as! [String: String]
            for (key, value) in cPageRangesToNames {
                codePageRangesToNames[Int(key)!] = value
            }
        } catch {
             NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        fontTypeControl.unbind(NSBindingName("objectValue"))
        fontSelectionControl.unbind(NSBindingName("objectValue"))
        let keys = ["version", "usWidthClass", "ySubscriptXSize", "ySubscriptYSize", "ySubscriptXOffset", "ySubscriptYOffset", "ySuperscriptXSize", "ySuperscriptYSize", "ySuperscriptXOffset", "ySuperscriptYOffset", "yStrikeoutSize", "yStrikeoutPosition", "sFamilyClass", "vendorID", "usFirstCharIndex", "usLastCharIndex", "sTypoAscender", "sTypoDescender", "sTypoLineGap", "usWinAscent", "usWinDescent", "sxHeight", "sCapHeight", "usDefaultChar", "usBreakChar", "usMaxContext", "usLowerOpticalPointSize", "usUpperOpticalPointSize"]
        keys.forEach({ table.removeObserver(self, forKeyPath: $0) })
    }

    override func viewDidLoad() {
        table.addObserver(self, forKeyPath: "version", options: [.new, .old], context: &table.version)
        table.addObserver(self, forKeyPath: "usWidthClass", options: [.new, .old], context: &table.usWidthClass)
        table.addObserver(self, forKeyPath: "ySubscriptXSize", options: [.new, .old], context: &table.ySubscriptXSize)
        table.addObserver(self, forKeyPath: "ySubscriptYSize", options: [.new, .old], context: &table.ySubscriptYSize)
        table.addObserver(self, forKeyPath: "ySubscriptXOffset", options: [.new, .old], context: &table.ySubscriptXOffset)
        table.addObserver(self, forKeyPath: "ySubscriptYOffset", options: [.new, .old], context: &table.ySubscriptYOffset)
        table.addObserver(self, forKeyPath: "ySuperscriptXSize", options: [.new, .old], context: &table.ySuperscriptXSize)
        table.addObserver(self, forKeyPath: "ySuperscriptYSize", options: [.new, .old], context: &table.ySuperscriptYSize)
        table.addObserver(self, forKeyPath: "ySuperscriptXOffset", options: [.new, .old], context: &table.ySuperscriptXOffset)
        table.addObserver(self, forKeyPath: "ySuperscriptYOffset", options: [.new, .old], context: &table.ySuperscriptYOffset)
        table.addObserver(self, forKeyPath: "yStrikeoutSize", options: [.new, .old], context: &table.yStrikeoutSize)
        table.addObserver(self, forKeyPath: "yStrikeoutPosition", options: [.new, .old], context: &table.yStrikeoutPosition)
        table.addObserver(self, forKeyPath: "sFamilyClass", options: [.new, .old], context: &table.sFamilyClass)
        table.addObserver(self, forKeyPath: "vendorID", options: [.new, .old], context: &table.vendorID)
        table.addObserver(self, forKeyPath: "usFirstCharIndex", options: [.new, .old], context: &table.usFirstCharIndex)
        table.addObserver(self, forKeyPath: "usLastCharIndex", options: [.new, .old], context: &table.usLastCharIndex)
        table.addObserver(self, forKeyPath: "sTypoAscender", options: [.new, .old], context: &table.sTypoAscender)
        table.addObserver(self, forKeyPath: "sTypoDescender", options: [.new, .old], context: &table.sTypoDescender)
        table.addObserver(self, forKeyPath: "sTypoLineGap", options: [.new, .old], context: &table.sTypoLineGap)
        table.addObserver(self, forKeyPath: "usWinAscent", options: [.new, .old], context: &table.usWinAscent)
        table.addObserver(self, forKeyPath: "usWinDescent", options: [.new, .old], context: &table.usWinDescent)
        table.addObserver(self, forKeyPath: "sxHeight", options: [.new, .old], context: &table.sxHeight)
        table.addObserver(self, forKeyPath: "sCapHeight", options: [.new, .old], context: &table.sCapHeight)
        table.addObserver(self, forKeyPath: "usDefaultChar", options: [.new, .old], context: &table.usDefaultChar)
        table.addObserver(self, forKeyPath: "usBreakChar", options: [.new, .old], context: &table.usBreakChar)
        table.addObserver(self, forKeyPath: "usMaxContext", options: [.new, .old], context: &table.usMaxContext)
        table.addObserver(self, forKeyPath: "usLowerOpticalPointSize", options: [.new, .old], context: &table.usLowerOpticalPointSize)
        table.addObserver(self, forKeyPath: "usUpperOpticalPointSize", options: [.new, .old], context: &table.usUpperOpticalPointSize)

        fontTypeControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "fsType", options: nil)
        fontSelectionControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "fsSelection", options: nil)
        super.viewDidLoad()
        updateUI()
    }

    override var representedObject: Any? {
        didSet {
            self.table = self.representedObject as! FontTable_OS2
        }
    }

    override func updateUI() {
        let views: [NSView] = [version1UnicodeView, codePageView, version2View, version5View]
        for view in views {
            for control: NSControl in view.subviews as! [NSControl] {
                control.isEnabled = table.version.rawValue >= control.tag
            }
        }
        if table.version < .version4 {
            fontSelectionControl.enabledMask = 0x7F
        } else {
            fontSelectionControl.enabledMask = 0x3FF
        }
        unicodeRangesTableView.reloadData()
        codeRangesTableView.reloadData()
    }

    @IBAction func showUnicodeRangePopover(_ sender: Any) {
        unicodeRangePopover.show(relativeTo: unicodeRangeButton.bounds, of: unicodeRangeButton, preferredEdge: .maxX)
    }

    @IBAction func showCodePageRangePopover(_ sender: Any) {
        let button = sender as! NSButton
        codePageRangePopover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxX)
    }

    @IBAction func changeVersion(_ sender: Any) {
        updateUI()
    }

    @IBAction func changeFontType(_ sender: Any) {
        guard let sender = sender as? NSButton else { return }
        let fontType: FontTable_OS2.FontType = .init(rawValue: UInt16(sender.tag))
        self.willChangeValue(forKey: "fsType")
        if sender.state == .on {
            fsType |= fontType.rawValue
        } else {
            fsType &= ~fontType.rawValue
        }
        self.didChangeValue(forKey: "fsType")
    }
    
    @IBAction func changeFontSelection(_ sender: Any) {
        guard let sender = sender as? NSButton else { return }
        let fontSelection: FontTable_OS2.Selection = .init(rawValue: UInt16(sender.tag))
        self.willChangeValue(forKey: "fsSelection")
        if sender.state == .on {
            fsSelection |= fontSelection.rawValue
        } else {
            fsSelection &= ~fontSelection.rawValue
        }
        self.didChangeValue(forKey: "fsSelection")
    }

    @IBAction func toggleUnicodeRange1(_ sender: Any) {
        let sender = sender as! NSButton
        let mask: FontTable_OS2.UnicodeMask1 = .init(rawValue: UInt32(1 << sender.tag))
        self.willChangeValue(forKey: "ulUnicodeRange1")
        if sender.state == .on {
            ulUnicodeRange1 |= mask.rawValue
        } else {
            ulUnicodeRange1 &= ~mask.rawValue
        }
        self.didChangeValue(forKey: "ulUnicodeRange1")
    }

    @IBAction func toggleUnicodeRange2(_ sender: Any) {
        let sender = sender as! NSButton
        let mask: FontTable_OS2.UnicodeMask2 = .init(rawValue: UInt32(1 << sender.tag))
        self.willChangeValue(forKey: "ulUnicodeRange2")
        if sender.state == .on {
            ulUnicodeRange2 |= mask.rawValue
        } else {
            ulUnicodeRange2 &= ~mask.rawValue
        }
        self.didChangeValue(forKey: "ulUnicodeRange2")
    }

    @IBAction func toggleUnicodeRange3(_ sender: Any) {
        let sender = sender as! NSButton
        let mask: FontTable_OS2.UnicodeMask3 = .init(rawValue: UInt32(1 << sender.tag))
        self.willChangeValue(forKey: "ulUnicodeRange3")
        if sender.state == .on {
            ulUnicodeRange3 |= mask.rawValue
        } else {
            ulUnicodeRange3 &= ~mask.rawValue
        }
        self.didChangeValue(forKey: "ulUnicodeRange3")
    }

    @IBAction func toggleUnicodeRange4(_ sender: Any) {
        let sender = sender as! NSButton
        let mask: FontTable_OS2.UnicodeMask4 = .init(rawValue: UInt32(1 << sender.tag))
        self.willChangeValue(forKey: "ulUnicodeRange4")
        if sender.state == .on {
            ulUnicodeRange4 |= mask.rawValue
        } else {
            ulUnicodeRange4 &= ~mask.rawValue
        }
        self.didChangeValue(forKey: "ulUnicodeRange4")
    }


    @IBAction func toggleCodePageRange1(_ sender: Any) {
        let sender = sender as! NSButton
        let mask: FontTable_OS2.CodePageMask1 = .init(rawValue: UInt32(1 << sender.tag))
        self.willChangeValue(forKey: "ulCodePageRange1")
        if sender.state == .on {
            ulCodePageRange1 |= mask.rawValue
        } else {
            ulCodePageRange1 &= ~mask.rawValue
        }
        self.didChangeValue(forKey: "ulCodePageRange1")
    }

    @IBAction func toggleCodePageRange2(_ sender: Any) {
        let sender = sender as! NSButton
        let mask: FontTable_OS2.CodePageMask2 = .init(rawValue: UInt32(1 << sender.tag))
        self.willChangeValue(forKey: "ulCodePageRange2")
        if sender.state == .on {
            ulCodePageRange2 |= mask.rawValue
        } else {
            ulCodePageRange2 &= ~mask.rawValue
        }
        self.didChangeValue(forKey: "ulCodePageRange2")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        NSLog("\(type(of: self)).\(#function) keyPath == \(String(describing: keyPath)), change == \(String(describing: change))")
        guard let context = context else {
            // call super?
            return
        }
        if context == &table.version {
            undoManager?.setActionName(NSLocalizedString("Change Version", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "version")
                $0.table.version = FontTable_OS2.Version(rawValue: change![.oldKey] as! UInt16)!
                $0.table.didChangeValue(forKey: "version")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.usWidthClass {
            undoManager?.setActionName(NSLocalizedString("Change Width Class", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "usWidthClass")
                $0.table.usWidthClass = FontTable_OS2.Width(rawValue: change![.oldKey] as! UInt16)!
                $0.table.didChangeValue(forKey: "usWidthClass")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.ySubscriptXSize {
            undoManager?.setActionName(NSLocalizedString("Change Subscript X Size", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "ySubscriptXSize")
                $0.table.ySubscriptXSize = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "ySubscriptXSize")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.ySubscriptYSize {
            undoManager?.setActionName(NSLocalizedString("Change Subscript Y Size", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "ySubscriptYSize")
                $0.table.ySubscriptYSize = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "ySubscriptYSize")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.ySubscriptXOffset {
            undoManager?.setActionName(NSLocalizedString("Change Subscript X Offset", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "ySubscriptXOffset")
                $0.table.ySubscriptXOffset = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "ySubscriptXOffset")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.ySubscriptYOffset {
            undoManager?.setActionName(NSLocalizedString("Change Subscript Y Offset", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "ySubscriptYOffset")
                $0.table.ySubscriptYOffset = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "ySubscriptYOffset")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.ySuperscriptXSize {
            undoManager?.setActionName(NSLocalizedString("Change Superscript X Size", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "ySuperscriptXSize")
                $0.table.ySuperscriptXSize = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "ySuperscriptXSize")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.ySuperscriptYSize {
            undoManager?.setActionName(NSLocalizedString("Change Superscript Y Size", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "ySuperscriptYSize")
                $0.table.ySuperscriptYSize = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "ySuperscriptYSize")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.ySuperscriptXOffset {
            undoManager?.setActionName(NSLocalizedString("Change Superscript X Offset", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "ySuperscriptXOffset")
                $0.table.ySuperscriptXOffset = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "ySuperscriptXOffset")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.ySuperscriptYOffset {
            undoManager?.setActionName(NSLocalizedString("Change Superscript Y Offset", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "ySuperscriptYOffset")
                $0.table.ySuperscriptYOffset = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "ySuperscriptYOffset")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.yStrikeoutSize {
            undoManager?.setActionName(NSLocalizedString("Change Strikeout Size", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "yStrikeoutSize")
                $0.table.yStrikeoutSize = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "yStrikeoutSize")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.yStrikeoutPosition {
            undoManager?.setActionName(NSLocalizedString("Change Strikeout Position", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "yStrikeoutPosition")
                $0.table.yStrikeoutPosition = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "yStrikeoutPosition")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.sFamilyClass {
            undoManager?.setActionName(NSLocalizedString("Change Family Class", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "sFamilyClass")
                $0.table.sFamilyClass = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "sFamilyClass")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.vendorID {
            undoManager?.setActionName(NSLocalizedString("Change Vendor ID", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "vendorID")
                $0.table.vendorID = change![.oldKey] as! Tag
                $0.table.didChangeValue(forKey: "vendorID")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.usFirstCharIndex {
            undoManager?.setActionName(NSLocalizedString("Change First Character", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "usFirstCharIndex")
                $0.table.usFirstCharIndex = change![.oldKey] as! UVBMP
                $0.table.didChangeValue(forKey: "usFirstCharIndex")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.usLastCharIndex {
            undoManager?.setActionName(NSLocalizedString("Change Last Character", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "usLastCharIndex")
                $0.table.usLastCharIndex = change![.oldKey] as! UVBMP
                $0.table.didChangeValue(forKey: "usLastCharIndex")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.sTypoAscender {
            undoManager?.setActionName(NSLocalizedString("Change Ascender", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "sTypoAscender")
                $0.table.sTypoAscender = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "sTypoAscender")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.sTypoDescender {
            undoManager?.setActionName(NSLocalizedString("Change Descender", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "sTypoDescender")
                $0.table.sTypoDescender = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "sTypoDescender")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.sTypoLineGap {
            undoManager?.setActionName(NSLocalizedString("Change Line Gap", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "sTypoLineGap")
                $0.table.sTypoLineGap = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "sTypoLineGap")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.usWinAscent {
            undoManager?.setActionName(NSLocalizedString("Change Windows Ascent", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "usWinAscent")
                $0.table.usWinAscent = change![.oldKey] as! UInt16
                $0.table.didChangeValue(forKey: "usWinAscent")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.usWinDescent {
            undoManager?.setActionName(NSLocalizedString("Change Windows Descent", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "usWinDescent")
                $0.table.usWinDescent = change![.oldKey] as! UInt16
                $0.table.didChangeValue(forKey: "usWinDescent")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.sxHeight {
            undoManager?.setActionName(NSLocalizedString("Change x-Height", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "sxHeight")
                $0.table.sxHeight = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "sxHeight")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.sCapHeight {
            undoManager?.setActionName(NSLocalizedString("Change Cap Height", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "sCapHeight")
                $0.table.sCapHeight = change![.oldKey] as! Int16
                $0.table.didChangeValue(forKey: "sCapHeight")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.usDefaultChar {
            undoManager?.setActionName(NSLocalizedString("Change Default Character", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "usDefaultChar")
                $0.table.usDefaultChar = change![.oldKey] as! UVBMP
                $0.table.didChangeValue(forKey: "usDefaultChar")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.usBreakChar {
            undoManager?.setActionName(NSLocalizedString("Change Break Character", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "usBreakChar")
                $0.table.usBreakChar = change![.oldKey] as! UVBMP
                $0.table.didChangeValue(forKey: "usBreakChar")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.usMaxContext {
            undoManager?.setActionName(NSLocalizedString("Change Max Context", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "usMaxContext")
                $0.table.usMaxContext = change![.oldKey] as! UInt16
                $0.table.didChangeValue(forKey: "usMaxContext")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.usLowerOpticalPointSize {
            undoManager?.setActionName(NSLocalizedString("Change Lower Optical Point Size", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "usLowerOpticalPointSize")
                $0.table.usLowerOpticalPointSize = change![.oldKey] as! UInt16
                $0.table.didChangeValue(forKey: "usLowerOpticalPointSize")
            })
            view.window?.isDocumentEdited = true
        } else if context == &table.usUpperOpticalPointSize {
            undoManager?.setActionName(NSLocalizedString("Change Upper Optical Point Size", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.willChangeValue(forKey: "usUpperOpticalPointSize")
                $0.table.usUpperOpticalPointSize = change![.oldKey] as! UInt16
                $0.table.didChangeValue(forKey: "usUpperOpticalPointSize")
            })
            view.window?.isDocumentEdited = true
        }
    }
}

extension ViewController_OS2: NSTableViewDelegate, NSTableViewDataSource {
    // MARK: - <NSTableViewDataSource>
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == unicodeRangesTableView {
            return 123
        } else {
            return 64
        }
    }

    // MARK: - <NSTableViewDelegate>
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == unicodeRangesTableView {
            let cellView: CheckboxTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("unicodeRangeTableCellView"), owner: self) as! CheckboxTableCellView
            cellView.textField!.stringValue = "\(row)"
            cellView.checkbox.title = unicodeBlocksToNames[row]!
            cellView.checkbox.target = self
            if row < 32 {
                cellView.checkbox.action = #selector(toggleUnicodeRange1(_:))
                cellView.checkbox.tag = row
                cellView.checkbox.state = ulUnicodeRange1 & (1 << row) != 0 ? .on : .off
                cellView.checkbox.isEnabled = table.version >= .version0
            } else if row >= 32 && row < 64 {
                cellView.checkbox.action = #selector(toggleUnicodeRange2(_:))
                cellView.checkbox.tag = row - 32
                cellView.checkbox.state = ulUnicodeRange2 & (1 << (row - 32)) != 0 ? .on: .off
                cellView.checkbox.isEnabled = table.version >= .version1
            } else if row >= 64 && row < 96 {
                cellView.checkbox.action = #selector(toggleUnicodeRange3(_:))
                cellView.checkbox.tag = row - 64
                cellView.checkbox.state = ulUnicodeRange3 & (1 << (row - 64)) != 0 ? .on: .off
                cellView.checkbox.isEnabled = table.version >= .version1
            } else {
                cellView.checkbox.action = #selector(toggleUnicodeRange4(_:))
                cellView.checkbox.tag = row - 96
                cellView.checkbox.state = ulUnicodeRange4 & (1 << (row - 96)) != 0 ? .on: .off
                cellView.checkbox.isEnabled = table.version >= .version1
            }
            return cellView
        } else {
            let cellView: CheckboxTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("codePageRangeTableCellView"), owner: self) as! CheckboxTableCellView
            cellView.textField!.stringValue = "\(row)"
            if let title = codePageRangesToNames[row] {
                cellView.checkbox.title = title
            } else {
                cellView.checkbox.title = NSLocalizedString("Reserved \(row)", comment: "")
            }
            cellView.checkbox.target = self
            if row < 32 {
                cellView.checkbox.action = #selector(toggleCodePageRange1(_:))
                cellView.checkbox.tag = row
                cellView.checkbox.state = ulCodePageRange1 & (1 << row) != 0 ? .on: .off
            } else {
                cellView.checkbox.action = #selector(toggleCodePageRange2(_:))
                cellView.checkbox.tag = row - 32
                cellView.checkbox.state = ulCodePageRange2 & (1 << (row - 32)) != 0 ? .on: .off
            }
            cellView.checkbox.isEnabled = table.version >= .version1
            return cellView
        }
    }
}

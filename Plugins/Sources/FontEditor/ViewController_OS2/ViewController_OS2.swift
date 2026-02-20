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

    @objc dynamic var ulUnicodeRange1:  UInt32 = 0 {
        didSet { unicodeRangesTableView.reloadData() }
    }

    @objc dynamic var ulUnicodeRange2:  UInt32 = 0 {
        didSet { unicodeRangesTableView.reloadData() }
    }

    @objc dynamic var ulUnicodeRange3:  UInt32 = 0 {
        didSet { unicodeRangesTableView.reloadData() }
    }

    @objc dynamic var ulUnicodeRange4:  UInt32 = 0 {
        didSet { unicodeRangesTableView.reloadData() }
    }

    @objc dynamic var ulCodePageRange1:  UInt32  = 0 {
        didSet { codeRangesTableView.reloadData() }
    }

    @objc dynamic var ulCodePageRange2:  UInt32  = 0 {
        didSet { codeRangesTableView.reloadData() }
    }

    @objc dynamic var usWeightClass:    UInt16 = 0
    @objc dynamic var fsType:           UInt16 = 0
    @objc dynamic var fsSelection:      UInt16 = 0

    private var unicodeBlocksToNames:   [Int: String] = [:]
    private var codePageRangesToNames:  [Int: String] = [:]
    private static var tableContext = 1
    private static let keyPaths = Set(["ulUnicodeRange1", "ulUnicodeRange2", "ulUnicodeRange3", "ulUnicodeRange4", "ulCodePageRange1",
                                       "ulCodePageRange2", "usWeightClass", "fsType", "fsSelection"])
    private static let tableKeyPaths = Set(["version", "usWidthClass", "ySubscriptXSize", "ySubscriptYSize",
        "ySubscriptXOffset", "ySubscriptYOffset", "ySuperscriptXSize", "ySuperscriptYSize", "ySuperscriptXOffset",
        "ySuperscriptYOffset", "yStrikeoutSize", "yStrikeoutPosition", "sFamilyClass", "vendorID", "usFirstCharIndex",
        "usLastCharIndex", "sTypoAscender", "sTypoDescender", "sTypoLineGap", "usWinAscent", "usWinDescent",
        "sxHeight", "sCapHeight", "usDefaultChar", "usBreakChar", "usMaxContext", "usLowerOpticalPointSize",
        "usUpperOpticalPointSize", "panose.bFamilyType", "panose.bSerifStyle", "panose.bWeight", "panose.bProportion",
        "panose.bContrast", "panose.bStrokeVariation", "panose.bArmStyle", "panose.bLetterform", "panose.bMidline", "panose.bXHeight"])

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
            let uBlocksToNames: [String: String] = try NSDictionary(contentsOf: Bundle.module.url(forResource: "UnicodeBlocksOS2", withExtension: "plist")!, error: ()) as! [String: String]
            for (key, value) in uBlocksToNames {
                unicodeBlocksToNames[Int(key)!] = value
            }
            let cPageRangesToNames: [String: String] = try NSDictionary(contentsOf: Bundle.module.url(forResource: "CodePageRangesOS2", withExtension: "plist")!, error: ()) as! [String: String]
            for (key, value) in cPageRangesToNames {
                codePageRangesToNames[Int(key)!] = value
            }
        } catch {
            NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
        }
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        fontTypeControl.unbind(NSBindingName("objectValue"))
        fontSelectionControl.unbind(NSBindingName("objectValue"))
        Self.keyPaths.forEach { removeObserver(self, forKeyPath: $0) }
        Self.tableKeyPaths.forEach { table.removeObserver(self, forKeyPath: $0) }
    }

    override func viewDidLoad() {
        Self.tableKeyPaths.forEach { table.addObserver(self, forKeyPath: $0, options: [.new, .old], context: &Self.tableContext) }
        Self.keyPaths.forEach { addObserver(self, forKeyPath: $0, options: [.new, .old], context: nil) }
        fontTypeControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "fsType", options: nil)
        fontSelectionControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "fsSelection", options: nil)
        super.viewDidLoad()
        updateUI()
    }

    override var representedObject: Any? {
        didSet {
            self.table = self.representedObject as! FontTable_OS2
            updateUI()
        }
    }

    override func prepareToSave() throws {
        NSLog("\(type(of: self)).\(#function)")
        table.usWeightClass = FontTable_OS2.Weight(rawValue: usWeightClass)
        table.fsType = FontTable_OS2.FontType(rawValue: fsType)
        table.ulUnicodeRange1 = FontTable_OS2.UnicodeMask1(rawValue: ulUnicodeRange1)
        table.ulUnicodeRange2 = FontTable_OS2.UnicodeMask2(rawValue: ulUnicodeRange2)
        table.ulUnicodeRange3 = FontTable_OS2.UnicodeMask3(rawValue: ulUnicodeRange3)
        table.ulUnicodeRange4 = FontTable_OS2.UnicodeMask4(rawValue: ulUnicodeRange4)
        table.ulCodePageRange1 = FontTable_OS2.CodePageMask1(rawValue: ulCodePageRange1)
        table.ulCodePageRange2 = FontTable_OS2.CodePageMask2(rawValue: ulCodePageRange2)
        table.fsSelection = FontTable_OS2.Selection(rawValue: fsSelection)
        view.window?.makeFirstResponder(nil)
    }

    override func updateUI() {
        // allow us to be called before nib is loaded
        guard let version1UnicodeView else { return }
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
        let sender = sender as! NSButton
        if sender.state == .on {
            fsType |= UInt16(sender.tag)
        } else {
            fsType &= ~UInt16(sender.tag)
        }
    }

    @IBAction func changeFontSelection(_ sender: Any) {
        let sender = sender as! NSButton
        if sender.state == .on {
            fsSelection |= UInt16(sender.tag)
        } else {
            fsSelection &= ~UInt16(sender.tag)
        }
    }

    @IBAction func toggleUnicodeRange1(_ sender: Any) {
        let sender = sender as! NSButton
        if sender.state == .on {
            ulUnicodeRange1 |= UInt32(1 << sender.tag)
        } else {
            ulUnicodeRange1 &= ~UInt32(1 << sender.tag)
        }
    }

    @IBAction func toggleUnicodeRange2(_ sender: Any) {
        let sender = sender as! NSButton
        if sender.state == .on {
            ulUnicodeRange2 |= UInt32(1 << sender.tag)
        } else {
            ulUnicodeRange2 &= ~UInt32(1 << sender.tag)
        }
    }

    @IBAction func toggleUnicodeRange3(_ sender: Any) {
        let sender = sender as! NSButton
        if sender.state == .on {
            ulUnicodeRange3 |= UInt32(1 << sender.tag)
        } else {
            ulUnicodeRange3 &= ~UInt32(1 << sender.tag)
        }
    }

    @IBAction func toggleUnicodeRange4(_ sender: Any) {
        let sender = sender as! NSButton
        if sender.state == .on {
            ulUnicodeRange4 |= UInt32(1 << sender.tag)
        } else {
            ulUnicodeRange4 &= ~UInt32(1 << sender.tag)
        }
    }

    @IBAction func toggleCodePageRange1(_ sender: Any) {
        let sender = sender as! NSButton
        if sender.state == .on {
            ulCodePageRange1 |= UInt32(1 << sender.tag)
        } else {
            ulCodePageRange1 &= ~UInt32(1 << sender.tag)
        }
    }

    @IBAction func toggleCodePageRange2(_ sender: Any) {
        let sender = sender as! NSButton
        if sender.state == .on {
            ulCodePageRange2 |= UInt32(1 << sender.tag)
        } else {
            ulCodePageRange2 &= ~UInt32(1 << sender.tag)
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
                $0.table.setValue(change![.oldKey], forKeyPath: keyPath)
                if keyPath == "version" { self.updateUI() }
            })
        } else {
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.setValue(change![.oldKey], forKey: keyPath)
            })
        }
        view.window?.isDocumentEdited = true
        if keyPath == "version" {
            undoManager?.setActionName(NSLocalizedString("Change Version", comment: ""))
        } else if keyPath == "usWidthClass" {
            undoManager?.setActionName(NSLocalizedString("Change Width Class", comment: ""))
        } else if keyPath == "ySubscriptXSize" {
            undoManager?.setActionName(NSLocalizedString("Change Subscript X Size", comment: ""))
        } else if keyPath == "ySubscriptYSize" {
            undoManager?.setActionName(NSLocalizedString("Change Subscript Y Size", comment: ""))
        } else if keyPath == "ySubscriptXOffset" {
            undoManager?.setActionName(NSLocalizedString("Change Subscript X Offset", comment: ""))
        } else if keyPath == "ySubscriptYOffset" {
            undoManager?.setActionName(NSLocalizedString("Change Subscript Y Offset", comment: ""))
        } else if keyPath == "ySuperscriptXSize" {
            undoManager?.setActionName(NSLocalizedString("Change Superscript X Size", comment: ""))
        } else if keyPath == "ySuperscriptYSize" {
            undoManager?.setActionName(NSLocalizedString("Change Superscript Y Size", comment: ""))
        } else if keyPath == "ySuperscriptXOffset" {
            undoManager?.setActionName(NSLocalizedString("Change Superscript X Offset", comment: ""))
        } else if keyPath == "ySuperscriptYOffset" {
            undoManager?.setActionName(NSLocalizedString("Change Superscript Y Offset", comment: ""))
        } else if keyPath == "yStrikeoutSize" {
            undoManager?.setActionName(NSLocalizedString("Change Strikeout Size", comment: ""))
        } else if keyPath == "yStrikeoutPosition" {
            undoManager?.setActionName(NSLocalizedString("Change Strikeout Position", comment: ""))
        } else if keyPath == "sFamilyClass" {
            undoManager?.setActionName(NSLocalizedString("Change Family Class", comment: ""))
        } else if keyPath == "vendorID" {
            undoManager?.setActionName(NSLocalizedString("Change Vendor ID", comment: ""))
        } else if keyPath == "usFirstCharIndex" {
            undoManager?.setActionName(NSLocalizedString("Change First Character", comment: ""))
        } else if keyPath == "usLastCharIndex" {
            undoManager?.setActionName(NSLocalizedString("Change Last Character", comment: ""))
        } else if keyPath == "sTypoAscender" {
            undoManager?.setActionName(NSLocalizedString("Change Ascender", comment: ""))
        } else if keyPath == "sTypoDescender" {
            undoManager?.setActionName(NSLocalizedString("Change Descender", comment: ""))
        } else if keyPath == "sTypoLineGap" {
            undoManager?.setActionName(NSLocalizedString("Change Line Gap", comment: ""))
        } else if keyPath == "usWinAscent" {
            undoManager?.setActionName(NSLocalizedString("Change Windows Ascent", comment: ""))
        } else if keyPath == "usWinDescent" {
            undoManager?.setActionName(NSLocalizedString("Change Windows Descent", comment: ""))
        } else if keyPath == "sxHeight" {
            undoManager?.setActionName(NSLocalizedString("Change x-Height", comment: ""))
        } else if keyPath == "sCapHeight" {
            undoManager?.setActionName(NSLocalizedString("Change Cap Height", comment: ""))
        } else if keyPath == "usDefaultChar" {
            undoManager?.setActionName(NSLocalizedString("Change Default Character", comment: ""))
        } else if keyPath == "usBreakChar" {
            undoManager?.setActionName(NSLocalizedString("Change Break Character", comment: ""))
        } else if keyPath == "usMaxContext" {
            undoManager?.setActionName(NSLocalizedString("Change Max Context", comment: ""))
        } else if keyPath == "usLowerOpticalPointSize" {
            undoManager?.setActionName(NSLocalizedString("Change Lower Optical Point Size", comment: ""))
        } else if keyPath == "usUpperOpticalPointSize" {
            undoManager?.setActionName(NSLocalizedString("Change Upper Optical Point Size", comment: ""))
        } else if keyPath == "panose.bFamilyType" {
            undoManager?.setActionName(NSLocalizedString("Change PANOSE Family Type", comment: ""))
        } else if keyPath == "panose.bSerifStyle" {
            undoManager?.setActionName(NSLocalizedString("Change PANOSE Serif Style", comment: ""))
        } else if keyPath == "panose.bWeight" {
            undoManager?.setActionName(NSLocalizedString("Change PANOSE Weight", comment: ""))
        } else if keyPath == "panose.bProportion" {
            undoManager?.setActionName(NSLocalizedString("Change PANOSE Proportion", comment: ""))
        } else if keyPath == "panose.bContrast" {
            undoManager?.setActionName(NSLocalizedString("Change PANOSE Contrast", comment: ""))
        } else if keyPath == "panose.bStrokeVariation" {
            undoManager?.setActionName(NSLocalizedString("Change PANOSE Stroke Variation", comment: ""))
        } else if keyPath == "panose.bArmStyle" {
            undoManager?.setActionName(NSLocalizedString("Change PANOSE Arm Style", comment: ""))
        } else if keyPath == "panose.bLetterform" {
            undoManager?.setActionName(NSLocalizedString("Change PANOSE Letterform", comment: ""))
        } else if keyPath == "panose.bMidline" {
            undoManager?.setActionName(NSLocalizedString("Change PANOSE Midline", comment: ""))
        } else if keyPath == "panose.bXHeight" {
            undoManager?.setActionName(NSLocalizedString("Change PANOSE x-Height", comment: ""))
        } else if keyPath.hasPrefix("ulUnicodeRange") {
            undoManager?.setActionName(NSLocalizedString("Change Unicode Range", comment: ""))
        } else if keyPath.hasPrefix("ulCodePageRange") {
            undoManager?.setActionName(NSLocalizedString("Change Code Page Range", comment: ""))
        } else if keyPath == "usWeightClass" {
            undoManager?.setActionName(NSLocalizedString("Change Weight", comment: ""))
        } else if keyPath == "fsType" {
            undoManager?.setActionName(NSLocalizedString("Change Font Type", comment: ""))
        } else if keyPath == "fsSelection" {
            undoManager?.setActionName("Change Font Selection")
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

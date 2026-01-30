//
//  ViewController_OS2.swift
//  FontEditor
//
//  Created by Mark Douma on 1/29/2026.
//

import Cocoa
import CoreFont
import RFSupport

class ViewController_OS2: FontTableViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var unicodeRangesTableView: NSTableView!
    @IBOutlet weak var codeRangesTableView: NSTableView!

    @IBOutlet weak var fontTypeControl: BitfieldControl!
    @IBOutlet weak var fontSelectionControl: BitfieldControl!

    @IBOutlet weak var version1UnicodeView: NSView!
    @IBOutlet weak var codePageView: NSView!
    @IBOutlet weak var version2View: NSView!
    @IBOutlet weak var version5View: NSView!

    @IBOutlet weak var ulUnicodeRange1Formatter: HexNumberFormatter!
    @IBOutlet weak var ulUnicodeRange2Formatter: HexNumberFormatter!
    @IBOutlet weak var ulCodePageRangeFormatter: HexNumberFormatter!

    var table:  FontTable_OS2

    @objc var usWeightClass:    UInt16 = 0
    @objc var fsType:           FontTable_OS2.FontType.RawValue = 0
    @objc var ulUnicodeRange1:  FontTable_OS2.UnicodeMask1.RawValue = 0 {
        didSet {
            unicodeRangesTableView.reloadData()
        }
    }

    @objc var ulUnicodeRange2:  FontTable_OS2.UnicodeMask2.RawValue = 0 {
        didSet {
            unicodeRangesTableView.reloadData()
        }
    }
    @objc var ulCodePageRange:  UInt64  = 0 {
        didSet {
            codeRangesTableView.reloadData()
        }
    }

    @objc var fsSelection:      FontTable_OS2.Selection.RawValue = 0

    private var unicodeBlocksToNames:   [Int: String] = [:]
    private var codePageRangesToNames:  [Int: String] = [:]

    required init?(with fontTable: FontTable) {
        table = fontTable as! FontTable_OS2
        usWeightClass = table.usWeightClass.rawValue
        fsType = table.fsType.rawValue
        ulUnicodeRange1 = table.ulUnicodeRange1.rawValue
        ulUnicodeRange2 = table.ulUnicodeRange2.rawValue
        ulCodePageRange = table.ulCodePageRange.rawValue
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
    
    override func viewDidLoad() {
        // AFAICT, a bug in IB limits formatter max to Int64.max
        ulUnicodeRange1Formatter.maximum = UInt64.max as NSNumber
        ulUnicodeRange2Formatter.maximum = UInt64.max as NSNumber
        ulCodePageRangeFormatter.maximum = UInt64.max as NSNumber
        fontTypeControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "fsType", options: nil)
        fontSelectionControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "fsSelection", options: nil)
        super.viewDidLoad()
        updateUI()
    }

    func updateUI() {
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

    @IBAction func changeVersion(_ sender: Any) {
        updateUI()
    }

    @IBAction func changeFontType(_ sender: Any) {
        guard let sender = sender as? NSButton else { return }
        let fontType: FontTable_OS2.FontType = .init(rawValue: UInt16(sender.tag))
//        let document = view.window?.windowController?.document
//        document?.undoManager?.setActionName(NSLocalizedString("Change Font Type", comment: ""))
//        document?.undoManager?.registerUndo(withTarget: self) { (self) in
//            self.fsType = fsType
//        }
        if sender.state == .on {
            fsType |= fontType.rawValue
        } else {
            fsType &= ~fontType.rawValue
        }

    }
    
    @IBAction func changeFontSelection(_ sender: Any) {
        guard let sender = sender as? NSButton else { return }
        let fontSelection: FontTable_OS2.Selection = .init(rawValue: UInt16(sender.tag))
        if sender.state == .on {
            fsSelection |= fontSelection.rawValue
        } else {
            fsSelection &= ~fontSelection.rawValue
        }
    }

    @IBAction func toggleUnicodeRange1(_ sender: Any) {
        let sender = sender as! NSButton
        let mask: FontTable_OS2.UnicodeMask1 = .init(rawValue: UInt64(1 << sender.tag))
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
        let mask: FontTable_OS2.UnicodeMask2 = .init(rawValue: UInt64(1 << sender.tag))
        self.willChangeValue(forKey: "ulUnicodeRange2")
        if sender.state == .on {
            ulUnicodeRange2 |= mask.rawValue
        } else {
            ulUnicodeRange2 &= ~mask.rawValue
        }
        self.didChangeValue(forKey: "ulUnicodeRange2")
    }

    @IBAction func toggleCodePageRange(_ sender: Any) {
        let sender = sender as! NSButton
        let mask: FontTable_OS2.CodePageMask = .init(rawValue: UInt64(1 << sender.tag))
        self.willChangeValue(forKey: "ulCodePageRange")
        if sender.state == .on {
            ulCodePageRange |= mask.rawValue
        } else {
            ulCodePageRange &= ~mask.rawValue
        }
        self.didChangeValue(forKey: "ulCodePageRange")
    }

    // MARK: <NSTableViewDataSource>
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == unicodeRangesTableView {
            return 123
        } else {
            return 64
        }
    }

    // MARK: <NSTableViewDelegate>
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == unicodeRangesTableView {
            let cellView: CheckboxTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("unicodeRangeTableCellView"), owner: self) as! CheckboxTableCellView
            cellView.textField!.stringValue = "\(row)"
            cellView.checkbox.title = unicodeBlocksToNames[row]!
            cellView.checkbox.target = self
            if row < 64 {
                cellView.checkbox.action = #selector(toggleUnicodeRange1(_:))
                cellView.checkbox.tag = row
                let mask: UInt64 = 1 << row
                cellView.checkbox.state = ulUnicodeRange1 & mask != 0 ? .on : .off
                if row < 32 {
                    cellView.checkbox.isEnabled = table.version >= .version0
                } else {
                    cellView.checkbox.isEnabled = table.version >= .version1
                }
            } else {
                cellView.checkbox.action = #selector(toggleUnicodeRange2(_:))
                cellView.checkbox.tag = row - 64
                let mask: UInt64 = 1 << (row - 64)
                cellView.checkbox.state = ulUnicodeRange2 & mask != 0 ? .on : .off
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
            cellView.checkbox.action = #selector(toggleCodePageRange(_:))
            cellView.checkbox.tag = row
            let mask: UInt64 = 1 << row
            cellView.checkbox.state = ulCodePageRange & mask != 0 ? .on : .off
            return cellView
        }
    }
}

//
//  ViewController_OS2.swift
//  FontEditor
//
//  Created by Mark Douma on 1/29/2026.
//

import Cocoa
import CoreFont
import RFSupport

final class ViewController_OS2: FontTableViewController, NSTableViewDelegate, NSTableViewDataSource {

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

    @objc var usWeightClass:    UInt16 = 0
    @objc var fsType:           FontTable_OS2.FontType.RawValue = 0

    @objc var ulUnicodeRange1:  FontTable_OS2.UnicodeMask1.RawValue = 0 {
        didSet {
            undoManager?.setActionName(NSLocalizedString("Change Unicode Range", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.willChangeValue(forKey: "ulUnicodeRange1")
                $0.ulUnicodeRange1 = oldValue
                $0.didChangeValue(forKey: "ulUnicodeRange1")
            })
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
            })
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
            codeRangesTableView.reloadData()
        }
    }

    @objc var fsSelection:      UInt16 = 0 

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
    }

    override func viewDidLoad() {
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
//        let document = windowController?.document
//        document?.undoManager?.setActionName(NSLocalizedString("Change Font Type", comment: ""))
//        document?.undoManager?.registerUndo(withTarget: self) { (self) in
//            self.fsType = fsType
//        }
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

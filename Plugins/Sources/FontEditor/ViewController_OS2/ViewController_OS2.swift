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

    var table:  FontTable_OS2

    private var unicodeBlocksToNames:   [Int: String] = [:]
    private var codePageRangesToNames:  [Int: String] = [:]

    required init?(with fontTable: FontTable) {
        table = fontTable as! FontTable_OS2
        super.init(with: fontTable)
        do {
            let uBlocksToNames: [String: String] = try NSDictionary(contentsOf: Bundle.module.url(forResource: "MDUnicodeBlocksOS2", withExtension: "plist")!, error: ()) as! [String: String]
            for (key, value) in uBlocksToNames {
                unicodeBlocksToNames[Int(key)!] = value
            }
            let cPageRangesToNames: [String: String] = try NSDictionary(contentsOf: Bundle.main.url(forResource: "MDCodePageRangesOS2", withExtension: "plist")!, error: ()) as! [String: String]
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
        NSLog("\(type(of: self)).\(#function)")
        super.viewDidLoad()
        fontTypeControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "representedObject.f", options: nil)
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

    }

    @IBAction func changeFontType(_ sender: Any) {

    }
    
    @IBAction func changeFontSelection(_ sender: Any) {

    }

    @IBAction func toggleUnicodeRange1(_ sender: Any) {

    }

    @IBAction func toggleUnicodeRange2(_ sender: Any) {

    }

    @IBAction func toggleCodePageRange(_ sender: Any) {
        
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
                cellView.checkbox.tag = 1 << row
                cellView.checkbox.state = table.ulUnicodeRange1.contains(FontTable_OS2.UnicodeMask1(rawValue: UInt64(1 << row))) ? .on : .off
                if row < 32 {
                    cellView.checkbox.isEnabled = table.version >= .version0
                } else {
                    cellView.checkbox.isEnabled = table.version >= .version1
                }
            } else {
                cellView.checkbox.action = #selector(toggleUnicodeRange2(_:))
                cellView.checkbox.tag = 1 << (row - 64)
                cellView.checkbox.state = table.ulUnicodeRange2.contains(FontTable_OS2.UnicodeMask2(rawValue: UInt64(1 << (row - 64)))) ? .on : .off
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
            cellView.checkbox.tag = 1 << row
            cellView.checkbox.state = table.ulCodePageRange.contains(FontTable_OS2.CodePageMask(rawValue: UInt64(1 << row))) ? .on : .off
            return cellView
        }
    }


}

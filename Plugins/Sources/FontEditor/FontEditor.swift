//
//  FontEditor.swift
//  FontEditor
//
//  Created by Mark Douma on 1/12/2026.
//

import Cocoa
import RFSupport
import CoreFont

public class FontEditor: AbstractEditor, ResourceEditor, ExportProvider {
    public static var bundle: Bundle { .module }
    public static let supportedTypes = [
        "sfnt",
    ]
    public static func register() {
        PluginRegistry.register(self)
    }

    @IBOutlet weak var tableView:       NSTableView!
    @IBOutlet weak var tableTagField:   NSTextField!
    @IBOutlet weak var box:             NSBox!

    public var resource: 		Resource        /// `'sfnt'`
    let manager: 		        RFEditorManager
    @objc var fontFile:         OTFFontFile

    private var tableTagsToViewControllers: [TableTag: FontTableViewController] = [:]
    private var originalData:   Data

    public override var windowNibName: NSNib.Name {
        return "FontEditor"
    }

    public static func filenameExtension(for resourceType: String) -> String {
        return resourceType == "sfnt" ? "ttf" : resourceType
    }

    public static func export(_ resource: Resource, to url: URL) throws {
        let data = resource.data
        try data.write(to: url)
    }

    public required init?(resource: Resource, manager: RFEditorManager) {
        self.resource = resource
        self.manager = manager
        do {
            originalData = resource.data
            fontFile = try OTFFontFile(resource.data)
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
            return nil
        }
        super.init(window: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func windowDidLoad() {
        super.windowDidLoad()
        window?.makeFirstResponder(tableView)
    }

    // FIXME: consolidate all loading view code when selection changes, etc.
    func reloadFont() {
        do {
            let indexes = tableView.selectedRowIndexes
            tableView.deselectAll(self)
            self.willChangeValue(forKey: "fontFile")
            fontFile = try OTFFontFile(resource.data)
            self.didChangeValue(forKey: "fontFile")
            box.contentView = Self.emptyView
            tableTagField.stringValue = ""
            tableTagsToViewControllers.removeAll()
            tableView.reloadData()
            if !indexes.isEmpty {
                tableView.selectRowIndexes(indexes, byExtendingSelection: false)
                let selectedDirEntry = fontFile.directory.entries[indexes.first!]
                let viewControllerClass = FontTableViewController.class(for: selectedDirEntry.tableTag).self
                guard let viewController = viewControllerClass.init(with: selectedDirEntry.table) else {
                    NSLog("\(type(of: self)).\(#function) failed to create a controller for \(selectedDirEntry.tableTag)")
                    return
                }
                box.contentView = viewController.view
                tableTagsToViewControllers[selectedDirEntry.tableTag] = viewController
                tableTagField.stringValue = selectedDirEntry.tableTag.fourCharString
            }
            window?.makeFirstResponder(tableView)
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
    }

    // MARK: -
    @IBAction public func saveResource(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")
        do {
            let tableTags: [TableTag] = tableTagsToViewControllers.keys.sorted(by: OTFReWritingOrderSort)
            try tableTags.forEach { try tableTagsToViewControllers[$0]!.prepareToSave() }
            resource.data = try fontFile.data()
            reloadFont()
            window?.isDocumentEdited = false
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
            self.presentError(error)
        }
    }

    @IBAction public func revertResource(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")

    }

    static let emptyView: NSView = NSView(frame: NSMakeRect(0, 0, 400, 600))
    static let supportedTableTags: Set<TableTag> = Set([.head, .maxp, .name, .post, .hhea, .hmtx, .OS_2, .gasp])
}

// MARK: -
extension FontEditor: NSTableViewDelegate, NSTableViewDataSource {
    // MARK: <NSTableViewDataSource>
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return fontFile.directory.entries.count
    }

    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let identifer = tableColumn?.identifier, identifer.rawValue == "index" {
            let entry = fontFile.directory.entries[row]
            return fontFile.tables.firstIndex(of: entry.table) ?? -1
        } else {
            return fontFile.directory.entries[row]
        }
    }

    // MARK: <NSTableViewDelegate>
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view: NSTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        guard let tableColumn, tableColumn.identifier.rawValue == "checksum" || tableColumn.identifier.rawValue == "tableTagString" else {
            view.textField?.font = .monospacedSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
            return view
        }
        let entry = fontFile.directory.entries[row]
        if tableColumn.identifier.rawValue == "tableTagString" {
            if Self.supportedTableTags.contains(entry.tableTag) {
                view.textField?.font = .monospacedSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .bold)
            } else {
                view.textField?.font = .monospacedSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
            }
        } else {
            let calcChecksum = entry.table.calculatedChecksum
            let isGood = entry.checksum == calcChecksum
            // FIXME: make this compatible with dark mode or not hard-coded
            view.textField?.textColor = isGood ? NSColor.labelColor : NSColor(srgbRed: 183.0/255.0, green: 130.0/255.0, blue: 0, alpha: 1.0)
            view.textField?.toolTip = isGood ? "" : String(format: NSLocalizedString("The calculated checksum is 0x%08X", comment: ""), calcChecksum)
            view.textField?.font = .monospacedSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
        }
        return view
    }

    public func tableViewSelectionDidChange(_ notification: Notification) {
//        NSLog("\(type(of: self)).\(#function) notification == \(notification)")
        let indexes = tableView.selectedRowIndexes
        if indexes.count != 1 {
            box.contentView = Self.emptyView
            tableTagField.stringValue = ""
            return
        }
        let selectedDirEntry: OTFsfntDirectoryEntry = fontFile.directory.entries[indexes.first!]
        let tag: TableTag = selectedDirEntry.table.tableTag
        if let existingViewController = tableTagsToViewControllers[tag] {
            box.contentView = existingViewController.view
            tableTagField.stringValue = tag.fourCharString
            return
        } else {
            let viewControllerClass: FontTableViewController.Type = FontTableViewController.class(for: tag).self
            guard let viewController = viewControllerClass.init(with: selectedDirEntry.table) else {
                NSLog("\(type(of: self)).\(#function) failed to create a controller for \(tag)")
                box.contentView = Self.emptyView
                tableTagField.stringValue = ""
                return
            }
            box.contentView = viewController.view
            tableTagsToViewControllers[tag] = viewController
            tableTagField.stringValue = tag.fourCharString
        }
    }
}

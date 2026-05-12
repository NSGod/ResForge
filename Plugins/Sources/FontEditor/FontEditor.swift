//
//  FontEditor.swift
//  FontEditor
//
//  Created by Mark Douma on 1/12/2026.
//

import Cocoa
import RFSupport
import CoreFont

// FIXME: allow separators (,) on textfield numerical input if possible

public final class FontEditor: AbstractEditor, ResourceEditor, ExportProvider, TypeIconProvider, FontImporterDelegate {
    public static var bundle: Bundle { .module }
    public static let supportedTypes = [
        "sfnt",
    ]
    public static func register() {
        PluginRegistry.register(self)
    }

    public static var typeIcons = [
        "sfnt": "trueTypeSymbol"
    ]

    @IBOutlet weak var tableView:                   NSTableView!
    @IBOutlet weak var tableTagField:               NSTextField!
    @IBOutlet weak var tableTagDescriptionField:    NSTextField!
    @IBOutlet weak var box:                         NSBox!

    public var resource:            Resource        /// `'sfnt'`
    @objc dynamic var fontFile:     OTFFontFile!
    let manager:                    RFEditorManager

    private var fontImporter:       FontImporterController?

    private static var dirEntryContext = 1
    private static var dirEntryKeyPaths = Set(["objcFormat", "searchRange", "entrySelector", "rangeShift"])

    private var tableTagsToViewControllers: [TableTag: FontTableViewController] = [:]

    public override var windowNibName: NSNib.Name {
        return "FontEditor"
    }

    public override var undoManager: UndoManager? {
        return window?.undoManager
    }

    public static func filenameExtension(for resourceType: String) -> String {
        return resourceType == "sfnt" ? "ttf" : resourceType
    }

    public static func export(_ resource: Resource, to url: URL) throws {
        let data = resource.data
        try data.write(to: url)
    }

    public required init?(resource: Resource, manager: RFEditorManager) {
        NSLog("\(type(of: self)).\(#function)")
        self.resource = resource
        self.manager = manager
        super.init(window: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSLog("\(type(of: self)).\(#function)")
        Self.dirEntryKeyPaths.forEach { fontFile?.directory.removeObserver(self, forKeyPath: $0) }
    }

    public override func windowDidLoad() {
        NSLog("\(type(of: self)).\(#function)")
        super.windowDidLoad()
        if resource.data.isEmpty {
            /// don't close the window, just hide it temporarily
            window?.orderOut(nil)
            fontImporter = FontImporterController(delegate: self, manager: manager)
            fontImporter?.showWindow(nil)
        } else {
            loadFont()
        }
    }

    public override func showWindow(_ sender: Any?) {
        NSLog("\(type(of: self)).\(#function)")
        fontImporter?.showWindow(sender) ?? super.showWindow(sender)
    }

    func updateUIForSelection() {

    }

    // FIXME: consolidate all loading view code when selection changes, etc.
    func loadFont() {
        do {
            let indexes = tableView.selectedRowIndexes
            tableView.deselectAll(self)
            box.contentView = Self.emptyView
            tableTagField.stringValue = ""
            tableTagDescriptionField.stringValue = ""
            tableTagsToViewControllers.removeAll()
            if let fontFile {
                Self.dirEntryKeyPaths.forEach { fontFile.directory.removeObserver(self, forKeyPath: $0) }
            }
            fontFile = try OTFFontFile(resource.data)
            Self.dirEntryKeyPaths.forEach { fontFile?.directory.addObserver(self, forKeyPath: $0, options: [.new, .old], context: &Self.dirEntryContext) }
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
                tableTagDescriptionField.stringValue = String(describing: selectedDirEntry.tableTag)
            }
            window?.makeFirstResponder(tableView)
        } catch {
            NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
            window?.presentError(error)
        }
    }

    // MARK: -
    @IBAction public func saveResource(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")
        do {
            let tableTags: [TableTag] = tableTagsToViewControllers.keys.sorted(by: OTFReWritingOrderSort)
            try tableTags.forEach { try tableTagsToViewControllers[$0]!.prepareToSave() }
            resource.data = try fontFile.data()
            loadFont()
            window?.isDocumentEdited = false
        } catch {
            NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
            self.presentError(error)
        }
    }

    @IBAction public func revertResource(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")
        loadFont()
        window?.isDocumentEdited = false
    }

    public func importFont(with data: Data, options: FontCreationOptions) {
        resource.data = data
        resource.name = options.fontFile.postScriptName
        resource.attributes = [.purgeable, .sysHeap]
        window?.makeKeyAndOrderFront(nil)
        window?.isDocumentEdited = true
        // FIXME: prevent duplicate ResIDs
        var fondResource: Resource?
        var fond: FOND?
        if options.createFOND {
            // FIXME: better matching than just resource name?
            if let existingFondResource = manager.findResource(type: .fond, name: options.fontFile.familyName, currentDocumentOnly: true) {
                do {
                    fond = try FOND(with: existingFondResource, options: options)
                    if let fond {
                        try fond.addEntry(for: Sfnt(resource: resource, fontFile: options.fontFile), options: options)
                        existingFondResource.data = try fond.data()
                    }
                } catch {
                    NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
                }
            } else {
                manager.createResource(type: .fond, id: Int(MacEncoding.resID(for: options.encoding.scriptID)), name: options.fontFile.familyName) { fondRes in
                    do {
                        fondRes.attributes = [.purgeable, .sysHeap]
                        fondResource = fondRes
                        fond = try FOND(with: fondRes, options: options)
                        if let fond, let entry = fond.fontAssociationTable.entries.first {
                            // do we really need to update our resID?
                            self.resource.id = Int(entry.fontID)
                            fondResource?.data = try fond.data()
                        }
                    } catch {
                        NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
                    }
                }
            }
        }
        loadFont()
        fontImporter?.close()
        fontImporter = nil
        // MARK: not sure yet how to handle NFNT creation
//        if let fond, let entry = fond.fontAssociationTable.entries.first {
//            resource.id = Int(entry.fontID)
//        }
//        if options.createNFNT, let sizes = options.sizes, sizes.count > 0 {
//            for size in sizes {
//                manager.createResource(type: .nfnt) { nfntResource in
//                    do {
//                        let nfnt = try NFNT(with: nfntResource, manager: self.manager, options: options, fontPointSize: Int16(size))
//                        nfntResource.data = try nfnt.data()
//                        if let fond {
//                            let entry = try FOND.FontAssociationTable.Entry()
//                            entry.fontPointSize = Int16(size)
//                            entry.fontStyle = options.fontFile.macStyle
//                            entry.fontID = ResID(nfntResource.id)
//                            try fond.add(entry)
//                        }
//                    } catch {
//                        NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
//                    }
//                }
//            }
//        }
//        if let fond, let fondResource {
//            do {
//                fondResource.data = try fond.data()
//            } catch {
//                NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
//            }
//        }
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath, Self.dirEntryKeyPaths.contains(keyPath), context == &Self.dirEntryContext else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        NSLog("\(type(of: self)).\(#function) keyPath: \(keyPath)")
        undoManager?.registerUndo(withTarget: self, handler: {
            $0.fontFile.directory.setValue(change![.oldKey], forKey: keyPath)
        })
        window?.isDocumentEdited = true
        if keyPath == "objcFormat" {
            undoManager?.setActionName(NSLocalizedString("Change Format", comment: ""))
        } else if keyPath == "searchRange" {
            undoManager?.setActionName(NSLocalizedString("Change Search Range", comment: ""))
        } else if keyPath == "entrySelector" {
            undoManager?.setActionName(NSLocalizedString("Change Entry Selector", comment: ""))
        } else if keyPath == "rangeShift" {
            undoManager?.setActionName(NSLocalizedString("Change Range Shift", comment: ""))
        }
    }

    static let emptyView: NSView = NSView(frame: NSMakeRect(0, 0, 400, 600))
    static var supportedTableTags: Set<TableTag> = {
        var mSupportedTableTags: Set<TableTag> = []
        for tableTag in TableTag.allCases {
            let className = NSStringFromClass(FontTableViewController.class(for: tableTag).self)
            if className != NSStringFromClass(FontTableDataViewController.self) {
                mSupportedTableTags.insert(tableTag)
            }
        }
        return mSupportedTableTags
    }()
}

// MARK: -
extension FontEditor: NSTableViewDelegate, NSTableViewDataSource {

    // MARK: - <NSControlTextEditingDelegate>
    public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if fieldEditor.string.isEmpty { return false }
        return true
    }

    // MARK: <NSTableViewDataSource>
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return fontFile?.directory.entries.count ?? 0
    }

    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let fontFile else { return nil }
        if let identifer = tableColumn?.identifier, identifer.rawValue == "index" {
            let entry = fontFile.directory.entries[row]
            return fontFile.tables.firstIndex(of: entry.table) ?? -1
        } else {
            return fontFile.directory.entries[row]
        }
    }

    // MARK: <NSTableViewDelegate>
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let fontFile else { return nil }
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
            // FIXME: make this more compatible with dark mode?
            view.textField?.textColor = isGood ? .labelColor : .systemOrange.shadow(withLevel: 0.2)
            view.textField?.toolTip = isGood ? "" : String(format: NSLocalizedString("The calculated checksum is 0x%08X", comment: ""), calcChecksum)
            view.textField?.font = .monospacedSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
        }
        return view
    }

    public func tableViewSelectionDidChange(_ notification: Notification) {
        // NSLog("\(type(of: self)).\(#function) notification == \(notification)")
        let indexes = tableView.selectedRowIndexes
        if indexes.count != 1 {
            box.contentView = Self.emptyView
            tableTagField.stringValue = ""
            tableTagDescriptionField.stringValue = ""
            return
        }
        let selectedDirEntry: OTFsfntDirectoryEntry = fontFile.directory.entries[indexes.first!]
        let tag: TableTag = selectedDirEntry.table.tableTag
        if let existingVC = tableTagsToViewControllers[tag] {
            box.contentView = existingVC.view
        } else if tag == .bdat || tag == .bloc, let existingVC = tableTagsToViewControllers[tag == .bdat ? .bloc : .bdat] {
            box.contentView = existingVC.view
            tableTagsToViewControllers[tag] = existingVC
        } else {
            let viewControllerClass: FontTableViewController.Type = FontTableViewController.class(for: tag).self
            guard let viewController = viewControllerClass.init(with: selectedDirEntry.table) else {
                NSLog("\(type(of: self)).\(#function) failed to create a controller for \(tag)")
                box.contentView = Self.emptyView
                tableTagField.stringValue = ""
                tableTagDescriptionField.stringValue = ""
                return
            }
            box.contentView = viewController.view
            tableTagsToViewControllers[tag] = viewController
        }
        tableTagField.stringValue = tag.fourCharString
        tableTagDescriptionField.stringValue = String(describing: tag)
    }
}

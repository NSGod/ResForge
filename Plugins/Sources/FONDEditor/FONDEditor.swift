//
//  FONDEditor.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/9/2025.
//

import Cocoa
import RFSupport
import CoreFont

public class FONDEditor : AbstractEditor, ResourceEditor {
    public static var bundle: Bundle { .module }
    public static let supportedTypes = [
        "FOND",
    ]
    public static func register() {
        PluginRegistry.register(self)
    }

    @IBOutlet weak var bBoxTableView:                   NSTableView!
    @IBOutlet weak var kernTableOutlineView:            NSOutlineView!
    @IBOutlet weak var glyphWidthsOutlineView:          NSOutlineView!
    @IBOutlet weak var flagsBitfieldControl:            BitfieldControl!
    @IBOutlet weak var fontClassBitfieldControl:        BitfieldControl!
    @IBOutlet weak var fontClassField:                  NSTextField!
    @IBOutlet weak var tableView:                       NSTableView! // font assoc. table entries

    @IBOutlet var fontAssocTableEntriesController:      NSArrayController!
    @IBOutlet var bBoxEntriesController:                NSArrayController!
    @IBOutlet var kernPairsTreeController:              NSTreeController!

    @IBOutlet weak var tabView:                         NSTabView!

    @IBOutlet var popover:                              NSPopover!
    @IBOutlet weak var popoverButton:                   NSButton!

    @IBOutlet weak var exportKernPairButton:            NSButton!

    public let resource:                    Resource
    private let manager:                    RFEditorManager
    @objc dynamic var fond:                 FOND

    @objc var kernPairs:                    [KernTreeNode] = []
    @objc var glyphWidths:                  [WidthTreeNode] = []

    @objc var glyphNameEntries:             [GlyphNameEntry] = []
    @objc var effectiveGlyphNameEntries:    [GlyphNameEntry] = []

    @objc dynamic var objcFFFlags:          UInt16 = 0
    @objc dynamic var objcFontClass:        UInt16 = 0

    private static var fondContext = 1
    private static let fondKeyPaths = Set(["famID", "firstChar", "lastChar", "ascent", "descent", "leading", "widMax",
        "wTabOff", "kernOff", "styleOff", "ewSPlain", "ewSBold", "ewSItalic", "ewSUnderline", "ewSOutline",
        "ewSShadow", "ewSCondensed", "ewSExtended", "ewSUnused", "intl0", "intl1", "ffVersion"])
    private static let keyPaths = Set(["objcFFFlags", "objcFontClass"])

    public override var windowNibName: NSNib.Name {
        "FONDEditor"
    }

    public override var undoManager: UndoManager? {
        return window?.undoManager
    }

    public required init?(resource: Resource, manager: RFEditorManager) {
        UserDefaults.standard.register(defaults: ["FONDEditor.selectedTabIndex": 0])
        self.resource = resource
        self.manager = manager
        do {
            fond = try FOND(with: self.resource)
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
            return nil
        }
        super.init(window: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        flagsBitfieldControl.unbind(NSBindingName("objectValue"))
        fontClassBitfieldControl.unbind(NSBindingName("objectValue"))
        Self.fondKeyPaths.forEach { fond.removeObserver(self, forKeyPath: $0) }
        Self.keyPaths.forEach { removeObserver(self, forKeyPath: $0) }
    }

    public override func windowDidLoad() {
        super.windowDidLoad()
        flagsBitfieldControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "objcFFFlags")
        fontClassBitfieldControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "objcFontClass")
        tabView.selectTabViewItem(at: UserDefaults.standard.integer(forKey: "FONDEditor.selectedTabIndex"))
        tableView.doubleAction = #selector(doubleClickOpenFont(_:))
        loadFOND()
        Self.fondKeyPaths.forEach { fond.addObserver(self, forKeyPath: $0, options: [.new, .old], context: &Self.fondContext) }
        Self.keyPaths.forEach { addObserver(self, forKeyPath: $0, options: [.new, .old], context: nil) }
    }

    public func windowWillClose(_ notification: Notification) {
        UserDefaults.standard.set(tabView.indexOfTabViewItem(tabView.selectedTabViewItem!), forKey: "FONDEditor.selectedTabIndex")
    }

    private func loadFOND() {
        fontClassBitfieldControl.isEnabled = fond.styleOff != 0
        fontClassField.isEnabled = fond.styleOff != 0
        if fond.boundingBoxTable != nil {
            tabView.tabViewItems[0].label = NSLocalizedString("✅ Bounding Box Table", comment: "")
        }
        if fond.kernOff != 0 {
            tabView.tabViewItems[1].label = NSLocalizedString("✅ Kern Table", comment: "")
        }
        if fond.wTabOff != 0 {
            tabView.tabViewItems[2].label = NSLocalizedString("✅ Glyph Width Table", comment: "")
        }
        if fond.styleMappingTable?.glyphNameEncodingSubtable != nil {
            tabView.tabViewItems[3].label = NSLocalizedString("✅ Glyph Name-Encoding Subtable", comment: "")
        }
        objcFFFlags = fond.ffFlags.rawValue
        objcFontClass = fond.styleMappingTable?.fontClass.rawValue ?? 0
        if let kernEntries = fond.kernTable?.entries {
            let kernPairs = kernEntries.map(KernTreeNode.init(representedObject:)).sorted(by: <)
            mutableArrayValue(forKey: "kernPairs").setArray(kernPairs)
        }
        if let widthEntries = fond.widthTable?.entries {
            let glyphWidths = widthEntries.map(WidthTreeNode.init(representedObject:)).sorted(by: <)
            mutableArrayValue(forKey: "glyphWidths").setArray(glyphWidths)
        }
        if let charCodesToGlyphNames = fond.styleMappingTable?.glyphNameEncodingSubtable?.charCodesToGlyphNames, charCodesToGlyphNames.count > 0 {
            let entries = GlyphNameEntry.glyphNameEntries(with: charCodesToGlyphNames)
            mutableArrayValue(forKey: "glyphNameEntries").setArray(entries)
        }
        // FIXME: should this be replacing rather than appending? YES
        mutableArrayValue(forKey: "effectiveGlyphNameEntries").setArray( fond.encoding.glyphNameEntries)
    }

    @IBAction func showPopover(_ sender: Any) {
        popover.show(relativeTo: popoverButton.bounds, of: popoverButton, preferredEdge: .minX)
    }

    @IBAction func changeFlags(_ sender: Any) {
        let sender = sender as! NSButton
        if sender.state == .on {
            objcFFFlags = objcFFFlags | UInt16(sender.tag)
        } else {
            objcFFFlags = objcFFFlags & ~UInt16(sender.tag)
        }
    }

    @IBAction func changeFontClass(_ sender: Any) {
        let sender = sender as! NSButton
        if sender.state == .on {
            objcFontClass = objcFontClass | UInt16(sender.tag)
        } else {
            objcFontClass = objcFontClass & ~UInt16(sender.tag)
        }
    }
    
    @IBAction public func saveResource(_ sender: Any) {
        fond.ffFlags = FOND.Flags(rawValue: objcFFFlags)
        fond.styleMappingTable?.fontClass = StyleMappingTable.FontClass(rawValue: objcFontClass)
        do {
            resource.data = try fond.data()
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
        self.setDocumentEdited(false)
    }

    @IBAction public func revertResource(_ sender: Any) {
        undoManager?.removeAllActions()
        do {
            fond = try FOND(with: resource)
            loadFOND()
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
        self.setDocumentEdited(false)
    }

    @IBAction func openFont(_ sender: Any) {
        // try to get the row of the button we clicked.
        guard let loc = NSApp.currentEvent?.locationInWindow else { return }
        let revLoc = tableView.convert(loc, from: nil)
        let row = tableView.row(at: revLoc)
        if row < 0 { return }
        openFont(at: row)
    }

    @IBAction func doubleClickOpenFont(_ sender: Any) {
        // Ignore double-clicks in table header
        guard tableView.clickedRow != -1 else { return }
        openFont(at: tableView.clickedRow)
    }

    private func openFont(at rowIndex: Int) {
        let entry = (fontAssocTableEntriesController.arrangedObjects as! [FontAssociationTable.Entry])[rowIndex]
        if let font: Resource = manager.findResource(type: ResourceType(entry.fontPointSize == 0 ? "sfnt" : "NFNT"), id: Int(entry.fontID), currentDocumentOnly: true) {
            manager.open(resource: font)
        }
    }

    @IBAction func exportKernPairs(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")
        let entries = selectedKernTableEntries()
        if entries.isEmpty { return }
        var panel: NSSavePanel!
        if entries.count == 1 {
            panel = NSSavePanel()
            panel.allowedFileTypes = [KernTable.Entry.GPOSFeatureUTType,
                                      KernTable.Entry.CSVUTType]
			let entry = entries[0]
			if let name = fond.postScriptNameForFont(with: entry.style) {
				if let filename = (name as NSString).appendingPathExtension("txt") {
					panel.nameFieldStringValue = filename
				}
			}
        } else {
            // if more than one entry, we need to export multiple files
            let oPanel = NSOpenPanel()
            oPanel.allowsMultipleSelection = false
            oPanel.canChooseFiles = false
            oPanel.canChooseDirectories = true
            oPanel.prompt = NSLocalizedString("Choose", comment: "")
            oPanel.message = NSLocalizedString("Choose the folder to export the kern pair files to", comment: "")
            panel = oPanel
        }
        panel.isExtensionHidden = false
        let viewController = KernPairSaveAccessoryViewController(with: panel)
        panel.accessoryView = viewController.view
        (panel as? NSOpenPanel)?.isAccessoryViewDisclosed = true
        panel.beginSheetModal(for: self.window!) { [self] (result) in
            if result == .OK {
                viewController.saveOptions()
                let config = viewController.config
                if entries.count == 1 {
                    guard let rep: String = entries.first!.representation(using: config, manager: manager) else { return }
                    do {
                        try rep.write(to: panel.url!, atomically: true, encoding: .utf8)
                    } catch {
                        NSLog("\(type(of: self)).\(#function) *** ERROR == \(error)")
                    }
                } else {
                    guard let parentDirURL = panel.url else { return }
                    for entry in entries {
                        if let name = fond.postScriptNameForFont(with: entry.style) {
                            guard let rep = entry.representation(using: config, manager: manager) else { continue }
                            let url = parentDirURL.appendingPathComponent(name).appendingPathExtension(config.pathExtension).assuringUniqueFilename()
                            do {
                                try rep.write(to: url, atomically: true, encoding: .utf8)
                            } catch {
                                 NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }

    private func selectedKernTableEntries() -> [CoreFont.KernTable.Entry] {
        guard let objs = kernPairsTreeController.selectedObjects as? [KernTreeNode] else { return [] }
        return objs.compactMap { $0.representedObject as? CoreFont.KernTable.Entry }
    }

    // MARK: - <NSMenuItemValidation>
    public override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let action = menuItem.action else { return false }
        if action == #selector(exportKernPairs) {
            let entries = selectedKernTableEntries()
            if entries.isEmpty {
                menuItem.title = NSLocalizedString("Export Kern Pair Entry…", comment: "")
                return false
            }
            if entries.count == 1 {
                if let name = fond.postScriptNameForFont(with: entries.first!.style) {
                    menuItem.title = NSLocalizedString("Export “\(name)” Kern Pairs…", comment: "")
                } else {
                    menuItem.title = NSLocalizedString("Export Kern Pair Entry…", comment: "")
                }
            } else {
                menuItem.title = NSLocalizedString("Export \(entries.count) Kern Pair Entries…", comment: "")
            }
            return true
        }
        return super.validateMenuItem(menuItem)
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        NSLog("\(type(of: self)).\(#function) keyPath : \(keyPath)")
        if !Self.fondKeyPaths.contains(keyPath) && !Self.keyPaths.contains(keyPath) {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        if context == &Self.fondContext {
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.setValue(change![.oldKey], forKeyPath: keyPath)
            })
        } else {
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.setValue(change![.oldKey], forKey: keyPath)
            })
        }
        window?.isDocumentEdited = true
        if keyPath == "objcFFFlags" {
            undoManager?.setActionName(NSLocalizedString("Change Font Family Flags", comment: ""))
        } else if keyPath == "famID" {
            undoManager?.setActionName(NSLocalizedString("Change Family ID", comment: ""))
        } else if keyPath == "firstChar" {
            undoManager?.setActionName(NSLocalizedString("Change First Character", comment: ""))
        } else if keyPath == "lastChar" {
            undoManager?.setActionName(NSLocalizedString("Change Last Character", comment: ""))
        } else if keyPath == "ascent" {
            undoManager?.setActionName(NSLocalizedString("Change Ascent", comment: ""))
        } else if keyPath == "descent" {
            undoManager?.setActionName(NSLocalizedString("Change Descent", comment: ""))
        } else if keyPath == "leading" {
            undoManager?.setActionName(NSLocalizedString("Change Leading", comment: ""))
        } else if keyPath == "widMax" {
            undoManager?.setActionName(NSLocalizedString("Change Maximum Width", comment: ""))
        } else if keyPath == "wTabOff" {
            undoManager?.setActionName(NSLocalizedString("Change Width Table Offset", comment: ""))
        } else if keyPath == "kernOff" {
            undoManager?.setActionName(NSLocalizedString("Change Kern Table Offset", comment: ""))
        } else if keyPath == "styleOff" {
            undoManager?.setActionName(NSLocalizedString("Change Style Table Offset", comment: ""))
        } else if keyPath == "ewSPlain" {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width for Plain", comment: ""))
        } else if keyPath == "ewSBold" {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width for Bold", comment: ""))
        } else if keyPath == "ewSItalic" {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width for Italic", comment: ""))
        } else if keyPath == "ewSUnderline" {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width for Underline", comment: ""))
        } else if keyPath == "ewSOutline" {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width for Outline", comment: ""))
        } else if keyPath == "ewSShadow" {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width for Shadow", comment: ""))
        } else if keyPath == "ewSCondensed" {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width for Condensed", comment: ""))
        } else if keyPath == "ewSExtended" {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width for Extended", comment: ""))
        } else if keyPath == "ewSUnused" {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width Unused", comment: ""))
        } else if keyPath == "intl0" {
            undoManager?.setActionName(NSLocalizedString("Change International 0", comment: ""))
        } else if keyPath == "intl1" {
            undoManager?.setActionName(NSLocalizedString("Change International 1", comment: ""))
        } else if keyPath == "ffVersion" {
            undoManager?.setActionName(NSLocalizedString("Change Version", comment: ""))
        } else if keyPath == "objcFontClass" {
            undoManager?.setActionName(NSLocalizedString("Change Font Class", comment: ""))
        }
    }
}

extension FONDEditor: NSTableViewDelegate, NSOutlineViewDelegate {
    // MARK: - <NSTableViewDelegate>
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == bBoxTableView {
            let view: NSTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
            if let id = tableColumn?.identifier, id.rawValue == "style" { return view }
            /// need to set the unitsPerEm of the Fixed4Dot12ToEmValueFormatter
            if let bboxEntries = bBoxEntriesController.arrangedObjects as? [BoundingBoxTable.Entry] {
                if let formatter = view.textField?.formatter as? Fixed4Dot12ToEmValueFormatter {
                    let entry = bboxEntries[row]
                    formatter.unitsPerEm = fond.unitsPerEm(for: entry.style, manager: manager)
                    return view
                }
            }
        } else if tableView == self.tableView {
            let view: NSTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
            if let id = tableColumn?.identifier, id.rawValue != "fontName" { return view }
            if let entries = fontAssocTableEntriesController.arrangedObjects as? [FontAssociationTable.Entry] {
                let entry = entries[row]
                if let fontName = fond.postScriptNameForFont(with: entry.fontStyle) {
                    let name = (entry.fontPointSize == 0 ? fontName : "\(fontName) \(entry.fontPointSize)")
                    view.textField?.stringValue = name
                } else {
                    view.textField?.stringValue = "--"
                }
            }
            return view
        }
        return nil
    }

    // MARK: - <NSOutlineViewDelegate>
    public func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else { return }
        if outlineView == kernTableOutlineView {
            let selectedEntries = selectedKernTableEntries()
            if selectedEntries.isEmpty {
                exportKernPairButton.title = NSLocalizedString("Export Kern Pair Entry…", comment: "")
                exportKernPairButton.isEnabled = false
            } else {
                exportKernPairButton.title = selectedEntries.count == 1 ? NSLocalizedString("Export Kern Pair Entry…", comment: "") : NSLocalizedString("Export \(selectedEntries.count) Kern Pair Entries…", comment: "")
                exportKernPairButton.isEnabled = true
            }
        }
    }

    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if outlineView == kernTableOutlineView {
            guard let representedObject = ((item as? NSTreeNode)?.representedObject as? KernTreeNode)?.representedObject else { return nil }
            if representedObject is CoreFont.KernTable.Entry {
                if tableColumn?.identifier.rawValue == "style"{
                    return outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
                } else if tableColumn?.identifier.rawValue == "kernWidth" {
                    return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("kernPairCount"), owner: self)
                }
                return nil
            } else if representedObject is KernPairNode {
                if tableColumn?.identifier.rawValue == "style" { return nil }
                let view: NSTableCellView = outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
                if let entry: CoreFont.KernTable.Entry = ((item as? NSTreeNode)?.representedObject as? KernTreeNode)?.parent?.representedObject as? CoreFont.KernTable.Entry {
                    if let formatter = view.textField?.formatter as? Fixed4Dot12ToEmValueFormatter {
                        formatter.unitsPerEm = fond.unitsPerEm(for: entry.style, manager: manager)
                    }
                    return view
                }
            }
        } else if outlineView == glyphWidthsOutlineView {
            if let item = item as? NSTreeNode, item.isLeaf {
                if tableColumn?.identifier.rawValue == "style" { return nil }
                let view: NSTableCellView = outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
                if tableColumn?.identifier.rawValue == "glyphWidth" {
                    if let entry: WidthTable.Entry = (item.representedObject as? WidthTreeNode)?.parent?.representedObject as? WidthTable.Entry {
                        if let formatter = view.textField?.formatter as? Fixed4Dot12ToEmValueFormatter {
                            formatter.unitsPerEm = fond.unitsPerEm(for: entry.style, manager: manager)
                        }
                    }
                }
                return view
            } else {
                if tableColumn?.identifier.rawValue == "style" {
                    return outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
                } else if tableColumn?.identifier.rawValue == "glyphWidth" {
                    return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("glyphWidthCount"), owner: self)
                }
            }
        }
        return nil
    }
}

//
//  FONDEditor.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/9/2025.
//

import Cocoa
import RFSupport
import CoreFont

// FIXME: this class is starting to get a bit unwieldy
public final class FONDEditor : AbstractEditor, ResourceEditor, NSControlTextEditingDelegate, NSTextFieldDelegate {
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
    @IBOutlet weak var fontNameSuffixTableView:         NSTableView!
    
    @IBOutlet var fontAssocTableEntriesController:      NSArrayController!
    @IBOutlet var bBoxEntriesController:                NSArrayController!
    @IBOutlet var kernPairsTreeController:              NSTreeController!
    @IBOutlet var fontNameSuffixEntriesController:      NSArrayController!
    
    @IBOutlet weak var tabView:                         NSTabView!
    @IBOutlet weak var encodingTabView:                 NSTabView!

    @IBOutlet var popover:                              NSPopover!
    @IBOutlet weak var popoverButton:                   NSButton!

    @IBOutlet weak var exportKernPairButton:            NSButton!

    public let resource:                    Resource
    private let manager:                    RFEditorManager
    @objc dynamic var fond:                 FOND

    @objc dynamic var kernPairs:                    [KernTreeNode] = []
    @objc dynamic var glyphWidths:                  [WidthTreeNode] = []

    @objc dynamic var glyphNameEntries:             [MacEncoding.GlyphNameEntry] = []
    @objc dynamic var effectiveGlyphNameEntries:    [MacEncoding.GlyphNameEntry] = []

    @objc dynamic var fontNameSuffixEntries:        [FontNameSuffixEntry] = []

    @objc dynamic var objcFFFlags:                  UInt16 = 0
    @objc dynamic var objcFontClass:                UInt16 = 0

    private static var fondContext = 1
    private static let fondKeyPaths = Set(["famID", "firstChar", "lastChar", "ascent", "descent", "leading", "widMax",
        "wTabOff", "kernOff", "styleOff", "ewSPlain", "ewSBold", "ewSItalic", "ewSUnderline", "ewSOutline",
        "ewSShadow", "ewSCondensed", "ewSExtended", "ewSUnused", "intl0", "intl1", "ffVersion"])
    private static let keyPaths = Set(["objcFFFlags", "objcFontClass"])
    private static let fontAsscKeyPaths = Set(["objcFontStyle", "fontPointSize", "fontID"])
    private static var fontAsscContext = 2
    
    private static var postScriptARedIcon: NSImage = {
        return NSImage(contentsOf: FONDEditor.bundle.url(forResource: "postScriptARed", withExtension: "pdf")!)!
    }()
    private static var trueTypeIcon: NSImage = {
        return NSImage(contentsOf: FONDEditor.bundle.url(forResource: "trueType", withExtension: "pdf")!)!
    }()

    public override var windowNibName: NSNib.Name {
        "FONDEditor"
    }

    public override var undoManager: UndoManager? {
        return window?.undoManager
    }

    public required init?(resource: Resource, manager: RFEditorManager) {
        UserDefaults.standard.register(defaults: ["FONDEditor.selectedTabIndex": 0,
                                                  "FONDEditor.selectedEncodingTabIndex": 1])
        self.resource = resource
        self.manager = manager
        do {
            fond = try FOND(with: self.resource)
        } catch {
            NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
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
        Self.fontAsscKeyPaths.forEach { (fond.fontAssociationTable.entries as NSArray).removeObserver(self, fromObjectsAt: IndexSet(0..<(fond.fontAssociationTable.entries.count)), forKeyPath: $0, context: &Self.fontAsscContext) }
    }

    public override func windowDidLoad() {
        super.windowDidLoad()
        flagsBitfieldControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "objcFFFlags")
        fontClassBitfieldControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "objcFontClass")
        tabView.selectTabViewItem(at: UserDefaults.standard.integer(forKey: "FONDEditor.selectedTabIndex"))
        encodingTabView.selectTabViewItem(at: UserDefaults.standard.integer(forKey: "FONDEditor.selectedEncodingTabIndex"))
        tableView.doubleAction = #selector(doubleClickOpenReferencedFont(_:))
        fontNameSuffixTableView.doubleAction = #selector(doubleClickOpenReferencedFont(_:))
        loadFOND()
        Self.fondKeyPaths.forEach { fond.addObserver(self, forKeyPath: $0, options: [.new, .old], context: &Self.fondContext) }
        Self.keyPaths.forEach { addObserver(self, forKeyPath: $0, options: [.new, .old], context: nil) }
        Self.fontAsscKeyPaths.forEach { (fond.fontAssociationTable.entries as NSArray).addObserver(self, toObjectsAt: IndexSet(0..<fond.fontAssociationTable.entries.count),  forKeyPath: $0, options: [.new, .old], context: &Self.fontAsscContext) }
    }

    public func windowWillClose(_ notification: Notification) {
        UserDefaults.standard.set(tabView.indexOfTabViewItem(tabView.selectedTabViewItem!), forKey: "FONDEditor.selectedTabIndex")
        UserDefaults.standard.set(encodingTabView.indexOfTabViewItem(encodingTabView.selectedTabViewItem!), forKey: "FONDEditor.selectedEncodingTabIndex")
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
            tabView.tabViewItems[3].label = NSLocalizedString("✅ Encoding", comment: "")
            encodingTabView.tabViewItems[1].label = NSLocalizedString("✅ Glyph Name-Encoding Subtable", comment: "")
        }
        if fond.styleMappingTable?.fontNameSuffixSubtable != nil {
            tabView.tabViewItems[4].label = NSLocalizedString("✅ Style-Mapping Table", comment: "")
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
            let entries = MacEncoding.GlyphNameEntry.entries(with: charCodesToGlyphNames).sorted(by: <)
            mutableArrayValue(forKey: "glyphNameEntries").setArray(entries)
        }
        // FIXME: !! should this be replacing rather than appending? YES
        mutableArrayValue(forKey: "effectiveGlyphNameEntries").setArray(fond.encoding.glyphNameEntries)
        if let fontNameSuffixSubtable = fond.styleMappingTable?.fontNameSuffixSubtable {
            let entries = FontNameSuffixEntry.entries(from: fontNameSuffixSubtable, manager: manager)
            mutableArrayValue(forKey: "fontNameSuffixEntries").setArray(entries)
        }
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
        fond.styleMappingTable?.fontClass = FOND.StyleMappingTable.FontClass(rawValue: objcFontClass)
        do {
            resource.data = try fond.data()
        } catch {
            NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
        }
        self.setDocumentEdited(false)
    }

    @IBAction public func revertResource(_ sender: Any) {
        undoManager?.removeAllActions()
        do {
            fond = try FOND(with: resource)
            loadFOND()
        } catch {
            NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
        }
        self.setDocumentEdited(false)
    }

    private enum SenderTag: Int {
        case fontAssociationTableView = 1
        case fontNameSuffixTableView = 2
    }

    // MARK: - open font association table fonts
    private func openFonts(at indexes: IndexSet) {
        let entries = ((fontAssocTableEntriesController.arrangedObjects as! [FOND.FontAssociationTable.Entry]) as NSArray).objects(at: indexes) as! [FOND.FontAssociationTable.Entry]
        entries.forEach {
            if let font = manager.findResource(type: $0.fontPointSize == 0 ? .sfnt : .nfnt, id: Int($0.fontID), currentDocumentOnly: true) {
                manager.open(resource: font)
            }
        }
    }

    // MARK: - open referenced fonts
    private func openReferencedFonts(at indexes: IndexSet) {
        let entries = ((fontNameSuffixEntriesController.arrangedObjects as! [FontNameSuffixEntry]) as NSArray).objects(at: indexes) as! [FontNameSuffixEntry]
        var urls: [URL] = []
        entries.forEach {
            if let sfntResID = $0.sfntResID, let sfnt = manager.findResource(type: .sfnt, id: Int(sfntResID), currentDocumentOnly: true) {
                manager.open(resource: sfnt)
            } else if let lwfnURL = $0.lwfnURL {
                if FileManager.default.fileExists(atPath: lwfnURL.path) { urls.append(lwfnURL) }
            }
        }
        if urls.count > 0 { NSWorkspace.shared.activateFileViewerSelecting(urls) }
    }

    /// `sender` can be an `->` `NSButton` or an `NSMenuItem`
    @IBAction func openReferencedFonts(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function) sender == \(sender)")
        guard let senderTag = SenderTag(rawValue: (sender as AnyObject).tag) else { return }
        if sender is NSMenuItem {
            if senderTag == .fontAssociationTableView {
                openFonts(at: fontAssocTableEntriesController.selectionIndexes)
            } else {
                openReferencedFonts(at: fontNameSuffixEntriesController.selectionIndexes)
            }
        } else if sender is NSButton {
            // try to get the row of the button we clicked
            guard let loc = NSApp.currentEvent?.locationInWindow else { return }
            if senderTag == .fontAssociationTableView {
                openFonts(at: IndexSet(integer: tableView.row(at: tableView.convert(loc, from: nil))))
            } else {
                openReferencedFonts(at: IndexSet.init(integer: fontNameSuffixTableView.row(at: fontNameSuffixTableView.convert(loc, from: nil))))
            }
        }
    }

    @IBAction func doubleClickOpenReferencedFont(_ sender: Any) {
        // Ignore double-clicks in table header:
        if (sender as! NSTableView).clickedRow < 0 { return }
        if tableView == sender as? NSTableView {
            openFonts(at: IndexSet(integer: tableView.clickedRow))
        } else {
            openReferencedFonts(at: IndexSet(integer: fontNameSuffixTableView.clickedRow))
        }
    }

    // MARK: - <NSControlTextEditingDelegate>
    @objc public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        return !fieldEditor.string.isEmpty
    }

    // MARK: -
    @IBAction func exportKernPairs(_ sender: Any) {
        let entries = selectedKernTableEntries()
        if entries.isEmpty { return }
        let exportController: KernPairExporterController = KernPairExporterController(entries: entries, editor: self, manager: manager)
        exportController.export()
    }

    private func selectedKernTableEntries() -> [FOND.KernTable.Entry] {
        guard let objs = kernPairsTreeController.selectedObjects as? [KernTreeNode] else { return [] }
        return objs.compactMap { $0.representedObject as? FOND.KernTable.Entry }
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
        } else if action == #selector(openReferencedFonts(_:)) {
            guard let tag = SenderTag(rawValue: menuItem.tag) else { return false }
            if tag == .fontAssociationTableView {
                let items = fontAssocTableEntriesController.selectedObjects as! [FOND.FontAssociationTable.Entry]
                if items.isEmpty {
                    menuItem.title = NSLocalizedString("Open Fonts", comment: "")
                } else if items.count == 1 {
                    menuItem.title = NSLocalizedString("Open “\(name(for: items.first!))”", comment: "")
                } else {
                    menuItem.title = NSLocalizedString("Open \(items.count) Fonts", comment: "")
                }
                return items.count > 0
            } else {
                let items = fontNameSuffixEntriesController.selectedObjects as! [FontNameSuffixEntry]
                let validItems = items.filter { $0.fontType == .sfnt || $0.fontType == .postScript }
                if validItems.isEmpty {
                    menuItem.title = NSLocalizedString("Open Fonts", comment: "")
                } else if validItems.count == 1 {
                    if validItems.first!.fontType == .sfnt {
                        menuItem.title = NSLocalizedString("Open “\(validItems.first!.postScriptName)”", comment: "")
                    } else {
                        menuItem.title = NSLocalizedString("Open “\(validItems.first!.lwfnFilename)”", comment: "")
                    }
                } else {
                    menuItem.title = NSLocalizedString("Open \(validItems.count) Fonts", comment: "")
                }
                return validItems.count > 0
            }
        }
        return super.validateMenuItem(menuItem)
    }

    public func name(for entry: FOND.FontAssociationTable.Entry) -> String {
        if let fontName = fond.postScriptNameForFont(with: entry.fontStyle) {
            return (entry.fontPointSize == 0 ? fontName : "\(fontName) \(entry.fontPointSize)")
        }
        return NSLocalizedString("--", comment: "")
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath, let object else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
//        NSLog("\(type(of: self)).\(#function) keyPath: \(keyPath), object: \(String(describing: object)), change: \(String(describing: change))")
        if !Self.fondKeyPaths.contains(keyPath) && !Self.keyPaths.contains(keyPath) && !Self.fontAsscKeyPaths.contains(keyPath) {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        if context == &Self.fondContext {
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.setValue(change![.oldKey], forKeyPath: keyPath)
            })
        } else if context == &Self.fontAsscContext {
            undoManager?.registerUndo(withTarget: self, handler: { _ in
                (object as? NSObject)?.setValue(change![.oldKey], forKey: keyPath)
                self.fond.fontAssociationTable.sortEntries()
                self.tableView.reloadData()
            })
            fond.fontAssociationTable.sortEntries()
            tableView.reloadData()
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
        } else if keyPath == "objcFontStyle" {
            undoManager?.setActionName(NSLocalizedString("Change Font Style", comment: ""))
        } else if keyPath == "fontPointSize" {
            undoManager?.setActionName(NSLocalizedString("Change Point Size", comment: ""))
        } else if keyPath == "fontID" {
            undoManager?.setActionName(NSLocalizedString("Change Font Resource ID", comment: ""))
        }
    }
}

extension FONDEditor: NSTableViewDelegate, NSOutlineViewDelegate {
    // MARK: - <NSTableViewDelegate>
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == bBoxTableView {
            let view: NSTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
            if let id = tableColumn?.identifier, id.rawValue == "style" { return view }
            /// need to set the unitsPerEm of the `Fixed4Dot12ToEmValueFormatter`
            if let bboxEntries = bBoxEntriesController.arrangedObjects as? [FOND.BoundingBoxTable.Entry] {
                if let formatter = view.textField?.formatter as? Fixed4Dot12ToEmValueFormatter {
                    let entry = bboxEntries[row]
                    formatter.unitsPerEm = fond.unitsPerEm(for: entry.style, manager: manager)
                    return view
                }
            }
        } else if tableView == self.tableView {
            let view: NSTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
            if let id = tableColumn?.identifier, id.rawValue != "fontName" {
                view.textField?.delegate = self
                return view
            }
            view.textField?.stringValue = name(for: (fontAssocTableEntriesController.arrangedObjects as! [FOND.FontAssociationTable.Entry])[row])
            return view
        } else if tableView == fontNameSuffixTableView {
            let entry = (fontNameSuffixEntriesController.arrangedObjects as! [FontNameSuffixEntry])[row]
            if entry.fontType == .none && tableColumn?.identifier.rawValue == "referencedFont" { return nil }
            let view: NSTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
            if tableColumn?.identifier.rawValue != "referencedFont" && tableColumn?.identifier.rawValue != "encodedStringRep" {
                return view
            }
            if tableColumn?.identifier.rawValue == "encodedStringRep" {
                view.textField?.attributedStringValue = entry.encodedAttrStringRepresentation
                return view
            }
            let bCellView = view as! ButtonTableCellView
            if entry.fontType == .sfnt {
                // bCellView.imageView?.image = NSImage(systemSymbolName: "f.cursive", accessibilityDescription: nil)
                bCellView.imageView?.image = Self.trueTypeIcon
                bCellView.textField?.stringValue = entry.postScriptName
            } else if entry.fontType == .postScript || entry.fontType == .missingPostScript {
                bCellView.imageView?.image = Self.postScriptARedIcon
                bCellView.textField?.stringValue = entry.lwfnFilename
                bCellView.textField?.textColor = entry.fontType == .missingPostScript ? .systemRed : .labelColor
                if entry.fontType == .missingPostScript { bCellView.textField?.toolTip = NSLocalizedString("\(entry.lwfnURL?.path ?? "Unknown") (missing)", comment: "") }
            }
            bCellView.button.tag = SenderTag.fontNameSuffixTableView.rawValue
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
            if representedObject is FOND.KernTable.Entry {
                if tableColumn?.identifier.rawValue == "style"{
                    return outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
                } else if tableColumn?.identifier.rawValue == "kernWidth" {
                    return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("kernPairCount"), owner: self)
                }
                return nil
            } else if representedObject is KernPairNode {
                if tableColumn?.identifier.rawValue == "style" { return nil }
                let view: NSTableCellView = outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
                if let entry: FOND.KernTable.Entry = ((item as? NSTreeNode)?.representedObject as? KernTreeNode)?.parent?.representedObject as? FOND.KernTable.Entry {
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
                    if let entry: FOND.WidthTable.Entry = (item.representedObject as? WidthTreeNode)?.parent?.representedObject as? FOND.WidthTable.Entry {
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

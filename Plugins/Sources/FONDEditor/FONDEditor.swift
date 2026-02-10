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
    @objc var fond:                         FOND

    @objc var kernPairs:                    [KernTreeNode] = []
    @objc var glyphWidths:                  [WidthTreeNode] = []

    @objc var glyphNameEntries:             [GlyphNameEntry] = []
    @objc var effectiveGlyphNameEntries:    [GlyphNameEntry] = []

    @objc var objcFFFlags:                  UInt16 = 0
    @objc var objcFontClass:                UInt16 = 0

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
        let fondKeys = ["famID", "firstChar", "lastChar", "ascent", "descent", "leading", "widMax", "wTabOff", "kernOff", "styleOff", "ewSPlain", "ewSBold", "ewSItalic", "ewSUnderline", "ewSOutline", "ewSShadow", "ewSCondensed", "ewSExtended", "ewSUnused", "intl0", "intl1", "ffVersion"]
        fondKeys.forEach( { fond.removeObserver(self, forKeyPath: $0) } )
        removeObserver(self, forKeyPath: "objcFFFlags")
        removeObserver(self, forKeyPath: "objcFontClass")
    }

    public override func windowDidLoad() {
        flagsBitfieldControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "objcFFFlags")
        fontClassBitfieldControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "objcFontClass")
        tabView.selectTabViewItem(at: UserDefaults.standard.integer(forKey: "FONDEditor.selectedTabIndex"))
        loadFOND()
        tableView.doubleAction = #selector(doubleClickOpenFont(_:))
        addObserver(self, forKeyPath: "objcFFFlags", options: [.new, .old], context: &objcFFFlags)
        fond.addObserver(self, forKeyPath: "famID", options: [.new, .old], context: &fond.famID)
        fond.addObserver(self, forKeyPath: "firstChar", options: [.new, .old], context: &fond.firstChar)
        fond.addObserver(self, forKeyPath: "lastChar", options: [.new, .old], context: &fond.lastChar)
        fond.addObserver(self, forKeyPath: "ascent", options: [.new, .old], context: &fond.ascent)
        fond.addObserver(self, forKeyPath: "descent", options: [.new, .old], context: &fond.descent)
        fond.addObserver(self, forKeyPath: "leading", options: [.new, .old], context: &fond.leading)
        fond.addObserver(self, forKeyPath: "widMax", options: [.new, .old], context: &fond.widMax)
        fond.addObserver(self, forKeyPath: "wTabOff", options: [.new, .old], context: &fond.wTabOff)
        fond.addObserver(self, forKeyPath: "kernOff", options: [.new, .old], context: &fond.kernOff)
        fond.addObserver(self, forKeyPath: "styleOff", options: [.new, .old], context: &fond.styleOff)
        fond.addObserver(self, forKeyPath: "ewSPlain", options: [.new, .old], context: &fond.ewSPlain)
        fond.addObserver(self, forKeyPath: "ewSBold", options: [.new, .old], context: &fond.ewSBold)
        fond.addObserver(self, forKeyPath: "ewSItalic", options: [.new, .old], context: &fond.ewSItalic)
        fond.addObserver(self, forKeyPath: "ewSUnderline", options: [.new, .old], context: &fond.ewSUnderline)
        fond.addObserver(self, forKeyPath: "ewSOutline", options: [.new, .old], context: &fond.ewSOutline)
        fond.addObserver(self, forKeyPath: "ewSShadow", options: [.new, .old], context: &fond.ewSShadow)
        fond.addObserver(self, forKeyPath: "ewSCondensed", options: [.new, .old], context: &fond.ewSCondensed)
        fond.addObserver(self, forKeyPath: "ewSExtended", options: [.new, .old], context: &fond.ewSExtended)
        fond.addObserver(self, forKeyPath: "ewSUnused", options: [.new, .old], context: &fond.ewSUnused)
        fond.addObserver(self, forKeyPath: "intl0", options: [.new, .old], context: &fond.intl0)
        fond.addObserver(self, forKeyPath: "intl1", options: [.new, .old], context: &fond.intl1)
        fond.addObserver(self, forKeyPath: "ffVersion", options: [.new, .old], context: &fond.ffVersion)
        addObserver(self, forKeyPath: "objcFontClass", options: [.new, .old], context: &objcFontClass)
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
        willChangeValue(forKey: "objcFFFlags")
        objcFFFlags = fond.ffFlags.rawValue
        didChangeValue(forKey: "objcFFFlags")
        willChangeValue(forKey: "objcFontClass")
        objcFontClass = fond.styleMappingTable?.fontClass.rawValue ?? 0
        didChangeValue(forKey: "objcFontClass")
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
        // FIXME: should this be replacing rather than appending?
        mutableArrayValue(forKey: "effectiveGlyphNameEntries").setArray( fond.encoding.glyphNameEntries)
    }

    @IBAction func showPopover(_ sender: Any) {
        popover.show(relativeTo: popoverButton.bounds, of: popoverButton, preferredEdge: .minX)
    }

    @IBAction func changeFlags(_ sender: Any) {
        let sender = sender as! NSButton
        willChangeValue(forKey: "objcFFFlags")
        if sender.state == .on {
            objcFFFlags = objcFFFlags | UInt16(sender.tag)
        } else {
            objcFFFlags = objcFFFlags & ~UInt16(sender.tag)
        }
        didChangeValue(forKey: "objcFFFlags")
    }

    @IBAction func changeFontClass(_ sender: Any) {
        let sender = sender as! NSButton
        willChangeValue(forKey: "objcFontClass")
        if sender.state == .on {
            objcFontClass = objcFontClass | UInt16(sender.tag)
        } else {
            objcFontClass = objcFontClass & ~UInt16(sender.tag)
        }
        didChangeValue(forKey: "objcFontClass")
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
        willChangeValue(forKey: "fond")
        do {
           fond = try FOND(with: resource)
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
        didChangeValue(forKey: "fond")
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

    private func selectedKernTableEntries() -> [KernTable.Entry] {
        guard let objs = kernPairsTreeController.selectedObjects as? [KernTreeNode] else { return [] }
        return objs.compactMap { $0.representedObject as? KernTable.Entry }
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
        NSLog("\(type(of: self)).\(#function) keyPath == \(String(describing: keyPath))")
        guard let context else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        if context == &objcFFFlags {
            undoManager?.setActionName(NSLocalizedString("Change Font Family Flags", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.willChangeValue(forKey: "objcFFFlags")
                $0.objcFFFlags = change![.oldKey] as! UInt16
                $0.didChangeValue(forKey: "objcFFFlags")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.famID {
            undoManager?.setActionName(NSLocalizedString("Change Family ID", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "famID")
                $0.fond.famID = change![.oldKey] as! ResID
                $0.fond.didChangeValue(forKey: "famID")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.firstChar {
            undoManager?.setActionName(NSLocalizedString("Change First Character", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "firstChar")
                $0.fond.firstChar = change![.oldKey] as! Int16
                $0.fond.didChangeValue(forKey: "firstChar")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.lastChar {
            undoManager?.setActionName(NSLocalizedString("Change Last Character", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "lastChar")
                $0.fond.lastChar = change![.oldKey] as! Int16
                $0.fond.didChangeValue(forKey: "lastChar")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.ascent {
            undoManager?.setActionName(NSLocalizedString("Change Ascent", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "ascent")
                $0.fond.ascent = change![.oldKey] as! Fixed4Dot12
                $0.fond.didChangeValue(forKey: "ascent")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.descent {
            undoManager?.setActionName(NSLocalizedString("Change Descent", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "descent")
                $0.fond.descent = change![.oldKey] as! Fixed4Dot12
                $0.fond.didChangeValue(forKey: "descent")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.leading {
            undoManager?.setActionName(NSLocalizedString("Change Leading", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "leading")
                $0.fond.leading = change![.oldKey] as! Fixed4Dot12
                $0.fond.didChangeValue(forKey: "leading")
            })
            window?.isDocumentEdited = true

        } else if context == &fond.widMax {
            undoManager?.setActionName(NSLocalizedString("Change Maximum Width", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "widMax")
                $0.fond.widMax = change![.oldKey] as! Fixed4Dot12
                $0.fond.didChangeValue(forKey: "widMax")
            })
            window?.isDocumentEdited = true

        } else if context == &fond.wTabOff {
            undoManager?.setActionName(NSLocalizedString("Change Width Table Offset", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "wTabOff")
                $0.fond.wTabOff = change![.oldKey] as! Int32
                $0.fond.didChangeValue(forKey: "wTabOff")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.kernOff {
            undoManager?.setActionName(NSLocalizedString("Change Kern Table Offset", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "kernOff")
                $0.fond.kernOff = change![.oldKey] as! Int32
                $0.fond.didChangeValue(forKey: "kernOff")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.styleOff {
            undoManager?.setActionName(NSLocalizedString("Change Style Table Offset", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "styleOff")
                $0.fond.styleOff = change![.oldKey] as! Int32
                $0.fond.didChangeValue(forKey: "styleOff")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.ewSPlain {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width for Plain", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "ewSPlain")
                $0.fond.ewSPlain = change![.oldKey] as! Fixed4Dot12
                $0.fond.didChangeValue(forKey: "ewSPlain")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.ewSBold {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width for Bold", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "ewSBold")
                $0.fond.ewSBold = change![.oldKey] as! Fixed4Dot12
                $0.fond.didChangeValue(forKey: "ewSBold")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.ewSItalic {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width for Italic", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "ewSItalic")
                $0.fond.ewSItalic = change![.oldKey] as! Fixed4Dot12
                $0.fond.didChangeValue(forKey: "ewSItalic")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.ewSUnderline {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width for Underline", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "ewSUnderline")
                $0.fond.ewSUnderline = change![.oldKey] as! Fixed4Dot12
                $0.fond.didChangeValue(forKey: "ewSUnderline")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.ewSOutline {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width for Outline", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "ewSOutline")
                $0.fond.ewSOutline = change![.oldKey] as! Fixed4Dot12
                $0.fond.didChangeValue(forKey: "ewSOutline")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.ewSShadow {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width for Shadow", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "ewSShadow")
                $0.fond.ewSShadow = change![.oldKey] as! Fixed4Dot12
                $0.fond.didChangeValue(forKey: "ewSShadow")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.ewSCondensed {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width for Condensed", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "ewSCondensed")
                $0.fond.ewSCondensed = change![.oldKey] as! Fixed4Dot12
                $0.fond.didChangeValue(forKey: "ewSCondensed")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.ewSExtended {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width for Extended", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "ewSExtended")
                $0.fond.ewSExtended = change![.oldKey] as! Fixed4Dot12
                $0.fond.didChangeValue(forKey: "ewSExtended")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.ewSUnused {
            undoManager?.setActionName(NSLocalizedString("Change Extra Width Unused", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "ewSUnused")
                $0.fond.ewSUnused = change![.oldKey] as! Fixed4Dot12
                $0.fond.didChangeValue(forKey: "ewSUnused")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.intl0 {
            undoManager?.setActionName(NSLocalizedString("Change International 0", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "intl0")
                $0.fond.intl0 = change![.oldKey] as! Fixed4Dot12
                $0.fond.didChangeValue(forKey: "intl0")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.intl1 {
            undoManager?.setActionName(NSLocalizedString("Change International 1", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "intl1")
                $0.fond.intl1 = change![.oldKey] as! Fixed4Dot12
                $0.fond.didChangeValue(forKey: "intl1")
            })
            window?.isDocumentEdited = true
        } else if context == &fond.ffVersion {
            undoManager?.setActionName(NSLocalizedString("Change Version", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.fond.willChangeValue(forKey: "ffVersion")
                $0.fond.ffVersion = FOND.Version(rawValue: change![.oldKey] as! UInt16)!
                $0.fond.didChangeValue(forKey: "ffVersion")
            })
            window?.isDocumentEdited = true
        } else if context == &objcFontClass {
            undoManager?.setActionName(NSLocalizedString("Change Font Class", comment: ""))
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.willChangeValue(forKey: "objcFontClass")
                $0.objcFontClass = change![.oldKey] as! UInt16
                $0.didChangeValue(forKey: "objcFontClass")
            })
            window?.isDocumentEdited = true
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
            if representedObject is KernTable.Entry {
                if tableColumn?.identifier.rawValue == "style"{
                    return outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
                } else if tableColumn?.identifier.rawValue == "kernWidth" {
                    return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("kernPairCount"), owner: self)
                }
                return nil
            } else if representedObject is KernPairNode {
                if tableColumn?.identifier.rawValue == "style" { return nil }
                let view: NSTableCellView = outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
                if let entry: KernTable.Entry = ((item as? NSTreeNode)?.representedObject as? KernTreeNode)?.parent?.representedObject as? KernTable.Entry {
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

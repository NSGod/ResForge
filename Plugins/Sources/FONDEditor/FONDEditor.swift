//
//  FONDEditor.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/9/2025.
//

import Cocoa
import RFSupport

public class FONDEditor : AbstractEditor, ResourceEditor, NSTableViewDelegate, NSOutlineViewDelegate {
    public static var bundle: Bundle { .module }
    public static let supportedTypes = [
        "FOND",
    ]
    public static func register() {
        PluginRegistry.register(self)
    }

    public let resource:                    Resource
    private let manager:                    RFEditorManager
    @objc var fond:                         FOND?

    @objc var kernPairs:                    [KernTreeNode] = []
    @objc var glyphWidths:                  [WidthTreeNode] = []

    @objc var glyphNameEntries:             [GlyphNameEntry] = []
    @objc var effectiveGlyphNameEntries:    [GlyphNameEntry] = []


    @IBOutlet weak var boundingBoxTableView:            NSTableView!
    @IBOutlet weak var kernTableOutlineView:            NSOutlineView!
    @IBOutlet weak var glyphWidthsOutlineView:          NSOutlineView!
    @IBOutlet weak var flagsBitfieldControl:            BitfieldControl!
    @IBOutlet weak var fontClassBitfieldControl:        BitfieldControl!

    @IBOutlet weak var tableView:                       NSTableView!

    @IBOutlet var popover:                              NSPopover!
    @IBOutlet weak var popoverButton:                   NSButton!

    @IBOutlet var boundingBoxTableEntriesController:    NSArrayController!

    @objc var objcFontClass:                            FontClass.RawValue = 0


    public override var windowNibName: NSNib.Name {
        "FONDEditorWindow"
    }

    public required init(resource: Resource, manager: RFEditorManager) {
        self.resource = resource
        self.manager = manager
        do {
            fond = try FOND(resource.data, resource: self.resource)
            objcFontClass = fond?.styleMappingTable?.objcFontClass ?? 0
            if let kernEntries = fond?.kernTable?.entries {
                for kernEntry in kernEntries {
                    let node = KernTreeNode(kernEntry)
                    kernPairs.append(node)
                }
                // FIXME: figure out sorting here
//                kernPairs.sort
//                kernPairs.sort { $0.left.value < $1.left.value }
            }
            if let widthEntries = fond?.widthTable?.entries {
                for widthEntry in widthEntries {
                    let node = WidthTreeNode(with: widthEntry)
                    glyphWidths.append(node)
                }
                // FIXME: figure out sorting here

            }
            if let charCodesToGlyphNames = fond?.styleMappingTable?.glyphNameEncodingSubtable?.charCodesToGlyphNames, charCodesToGlyphNames.count > 0 {
                let entries = GlyphNameEntry.glyphNameEntries(with: charCodesToGlyphNames)
                glyphNameEntries.append(contentsOf: entries)
            }
            effectiveGlyphNameEntries.append(contentsOf: fond!.encoding.glyphNameEntries)

        } catch {
             NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
        super.init(window: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func windowDidLoad() {
        flagsBitfieldControl.bind(NSBindingName(rawValue: "objectValue"), to: self, withKeyPath: "fond.objcFFFlags")
        fontClassBitfieldControl.bind(NSBindingName(rawValue: "objectValue"), to: self, withKeyPath: "objcFontClass")
        fond?.styleMappingTable?.bind(NSBindingName(rawValue: "objcFontClass"), to: self, withKeyPath: "objcFontClass")
    }

    @IBAction func showPopover(_ sender: Any) {
        popover.show(relativeTo: popoverButton.bounds, of: popoverButton, preferredEdge: .maxX)
    }

    @IBAction func changeFlags(_ sender: Any) {
        guard let sender = sender as? NSButton else { return }
        guard let fond = fond else { return }
        let isOn = sender.state == .on
//        self.willChangeValue(forKey: "fond.objcFFFlags")
        if isOn {
            fond.objcFFFlags = fond.objcFFFlags | UInt16(sender.tag)
        } else {
            fond.objcFFFlags = fond.objcFFFlags & ~UInt16(sender.tag)
        }
//        self.didChangeValue(forKey: "fond.objcFFFlags")
    }

    @IBAction func changeFontClass(_ sender: Any) {
        guard let sender = sender as? NSButton else { return }
        let isOn = sender.state == .on
        if isOn {
            self.objcFontClass = objcFontClass | UInt16(sender.tag)
        } else {
            self.objcFontClass = objcFontClass & ~UInt16(sender.tag)
        }
    }

    // MARK: - <NSTableViewDelegate>
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == boundingBoxTableView {
            let view: NSTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
            if let id = tableColumn?.identifier, id.rawValue == "style" { return view }
            /// need to set the unitsPerEm of the Fixed4Dot12ToEmValueFormatter
            if let bboxEntries = boundingBoxTableEntriesController.arrangedObjects as? [BoundingBoxTableEntry] {
                if let formatter = view.textField?.formatter as? Fixed4Dot12ToEmValueFormatter {
                    let entry = bboxEntries[row]
                    formatter.unitsPerEm = fond?.unitsPerEm(for: entry.style) ?? .postScriptStandard
                    return view
                }
            }
        }
        return nil
    }

    // MARK: - <NSOutlineViewDelegate>
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if outlineView == kernTableOutlineView {
            guard let representedObject = ((item as? NSTreeNode)?.representedObject as? KernTreeNode)?.representedObject else { return nil }
            if representedObject is KernTableEntry {
                if tableColumn?.identifier.rawValue == "style"{
                    return outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
                } else if tableColumn?.identifier.rawValue == "kernWidth" {
                    return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("kernPairCount"), owner: self)
                }
                return nil
            } else if representedObject is KernPairNode {
                if tableColumn?.identifier.rawValue == "style" { return nil }
                let view: NSTableCellView = outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
                if let entry: KernTableEntry = ((item as? NSTreeNode)?.representedObject as? KernTreeNode)?.parent?.representedObject as? KernTableEntry {
                    if let formatter = view.textField?.formatter as? Fixed4Dot12ToEmValueFormatter {
                        formatter.unitsPerEm = fond?.unitsPerEm(for: entry.style) ?? .postScriptStandard
                    }
                    return view
                }
            }
        } else if outlineView == glyphWidthsOutlineView {
            if let item = item as? NSTreeNode, item.isLeaf {
                if tableColumn?.identifier.rawValue == "style" { return nil }
                let view: NSTableCellView = outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
                if tableColumn?.identifier.rawValue == "glyphWidth" {
                    if let entry: WidthTableEntry = (item.representedObject as? KernTreeNode)?.parent?.representedObject as? WidthTableEntry {
                        if let formatter = view.textField?.formatter as? Fixed4Dot12ToEmValueFormatter {
                            formatter.unitsPerEm = fond?.unitsPerEm(for: entry.style) ?? .postScriptStandard
                        }
                    }
                }
                return view
            } else {
                if tableColumn?.identifier.rawValue == "style" {
                    return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("style"), owner: self)
                } else if tableColumn?.identifier.rawValue == "glyphWidth" {
                    return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("glyphWidthCount"), owner: self)
                }
            }
        }
        return nil
    }

    @IBAction public func saveResource(_ sender: Any) {


    }

    @IBAction public func revertResource(_ sender: Any) {

    }



    
}

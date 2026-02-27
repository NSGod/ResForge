//
//  ViewController_cmap.swift
//  FontEditor
//
//  Created by Mark Douma on 2/25/2026.
//

import Cocoa
import CoreFont
import RFSupport

final class ViewController_cmap: FontTableViewController {
    @IBOutlet var encodingsController: NSTreeController!

    @objc dynamic var encodings:    [CmapTreeNode] = []
    var table:                      FontTable_cmap

    required init?(with fontTable: FontTable) {
        table = fontTable as! FontTable_cmap
        super.init(with: table)
        for encoding in table.encodings {
            encodings.append(.init(with: encoding))
        }
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ViewController_cmap: NSOutlineViewDelegate {

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let node: CmapTreeNode = (item as? NSTreeNode)?.representedObject as? CmapTreeNode else { return nil }
        let identifier = tableColumn?.identifier.rawValue ?? ""
        let isLeaf = node.isLeaf
        if isLeaf {
            if identifier == "glyphName" {
                let cellView: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("glyphName"), owner: self) as! NSTableCellView
                let glyphMapping = node.representedObject as! FontTable_cmap.GlyphMapping
                cellView.textField?.textColor = (glyphMapping.hasMappingConflict ? .red : .controlTextColor)
                return cellView
            } else {
                return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(identifier), owner: self)
            }
        } else {
            if identifier == "charValue" {
                return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("format"), owner: self)
            } else if identifier == "charName" {
                return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("platformScriptName"), owner: self)
            } else if identifier == "glyphID" {
                return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("languageName"), owner: self)
            } else {
                return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("count"), owner: self)
            }
        }
    }
}

//
//  FontEditor.swift
//  FontEditor
//
//  Created by Mark Douma on 1/12/2026.
//

import Cocoa
import RFSupport


public class FontEditor: AbstractEditor, ResourceEditor, NSTableViewDelegate, NSTableViewDataSource {
    public static var bundle: Bundle { .module }
    public static let supportedTypes = [
        "sfnt",
    ]
    public static func register() {
        PluginRegistry.register(self)
    }

    @IBOutlet weak var directoryEntriesTableView: NSTableView!
    
    public var resource: 		Resource
    let manager: 		        RFEditorManager
    @objc var fontFile:         OTFFontFile

    public override var windowNibName: NSNib.Name {
        return "FontEditor"
    }

    public required init?(resource: Resource, manager: RFEditorManager) {
        self.resource = resource
        self.manager = manager
        do {
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

    }

    // MARK: - <NSTableViewDataSource>
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
    // MARK: -
    public func saveResource(_ sender: Any) {

    }

    public func revertResource(_ sender: Any) {

    }
}

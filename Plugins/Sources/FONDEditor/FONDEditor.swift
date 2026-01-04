//
//  FONDEditor.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/9/2025.
//

import Cocoa
import RFSupport

public class FONDEditor : AbstractEditor, ResourceEditor {
    public static var bundle: Bundle { .module }
    public static let supportedTypes = [
        "FOND",
    ]
    public static func register() {
        PluginRegistry.register(self)
    }
    public let resource:    Resource
    private let manager:    RFEditorManager
    var fond:               FOND?

    @IBOutlet weak var tableView:                   NSTableView!
    @IBOutlet weak var flagsBitfieldControl:        BitfieldControl!
    @IBOutlet weak var fontClassBitfieldControl:    BitfieldControl!
    
    
    @IBAction func changeFlags(_ sender: Any) {
        
    }
    
    @IBAction func changeFontClass(_ sender: Any) {
        
    }
    
    public override var windowNibName: NSNib.Name {
        "FONDEditorWindow"
    }

    public required init(resource: Resource, manager: RFEditorManager) {
        self.resource = resource
        self.manager = manager
//        self.fond = try FOND(resource.data)
        do {
            self.fond = try FOND(resource.data, resource: self.resource)
//            super.init(window: nil)

        } catch {
            // NSLog("\(type(of: self)).\(#function)() *** error: \(error)")

        }
        super.init(window: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func windowDidLoad() {
//        loadFOND()
    }

//    private func loadFOND() {
//        do {
//            fond = try FOND(resource.data)
//
//        } catch {
//            // NSLog("\(type(of: self)).\(#function)() *** error: \(error)")
////            statements
//        }
//
//    }

    @IBAction public func saveResource(_ sender: Any) {


    }

    @IBAction public func revertResource(_ sender: Any) {

    }



    
}

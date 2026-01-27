//
//  POSTExporter.swift
//  POSTExporter
//
//  Created by Mark Douma on 1/17/2026.
//

import Cocoa
import RFSupport
import CoreFont

public class POSTExporter: AbstractEditor, ResourceEditor, ExportProvider, TypeIconProvider {
    @IBOutlet weak var sampleTextField:     NSTextField!

    public static var bundle: Bundle { .module }
    public static let supportedTypes: [String] = [
        "POST"
    ]
    public static func register() {
        PluginRegistry.register(self)
    }
    public static func filenameExtension(for resourceType: String) -> String {
        return resourceType == "POST" ? "pfa" : resourceType
    }
    public static var typeIcons = [
        "POST": "postScriptA"
    ]

    public override var windowNibName: NSNib.Name {
        return "POSTExporter"
    }

    public var resource:        Resource
    private let manager:        RFEditorManager
    private var _windowTitle:   String = ""

    @objc public var pfaFile:   PostScriptType1FontFile!

    required public init?(resource: Resource, manager: any RFEditorManager) {
        self.resource = resource
        self.manager = manager
        super.init(window: nil)
        var resources: [Resource] = manager.allResources(ofType: ResourceType("POST"), currentDocumentOnly: true)
        // MARK: make sure to sort the 'POST' resources by ID in case they're out of order (by indexes) in the font file
        resources.sort { $0.id < $1.id }
        do {
            let postResources: [POST] = try POST.postResources(from: resources)
            guard let pfaData = try POST.data(from: postResources) else {
                // FIXME: present error
                return nil
            }
            pfaFile = try PostScriptType1FontFile(data: pfaData, options: .full)
            _windowTitle = "POST 501 – \(501 + resources.count): \(pfaFile.postScriptName)"
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
            return nil
        }
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    public var windowTitle: String {
        return _windowTitle
    }

    public override func windowDidLoad() {
        super.windowDidLoad()
        sampleTextField.font = pfaFile.font
    }

    public func windowWillClose(_ notification: Notification) {
        NSLog("\(type(of: self)).\(#function)")
        do {
            try pfaFile.deactivate()
        } catch {
             NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
    }

    public override func showWindow(_ sender: Any?) {
        NSLog("\(type(of: self)).\(#function)")
        super.showWindow(sender)
    }

    public static func export(_ resource: Resource, to url: URL) throws {
//        if let document
    }

    public func saveResource(_ sender: Any) {

    }

    public func revertResource(_ sender: Any) {

    }
}

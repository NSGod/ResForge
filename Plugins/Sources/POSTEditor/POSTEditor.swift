//
//  POSTEditor.swift
//  POSTEditor
//
//  Created by Mark Douma on 1/17/2026.
//

import Cocoa
import RFSupport

public class POSTEditor: AbstractEditor, ResourceEditor, TypeIconProvider {
    public static var bundle: Bundle { .module }
    public static let supportedTypes: [String] = [
        "POST"
    ]
    public static func register() {
        PluginRegistry.register(self)
    }

    public var resource:               Resource
    private let manager:        RFEditorManager

    public static var typeIcons = [
        "POST": "postScriptA"
    ]

    public override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    required public init?(resource: Resource, manager: any RFEditorManager) {
        self.resource = resource
        self.manager = manager
        return nil
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    public func saveResource(_ sender: Any) {

    }

    public func revertResource(_ sender: Any) {

    }
}

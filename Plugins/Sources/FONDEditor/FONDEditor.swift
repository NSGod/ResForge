//
//  FONDEditor.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/9/2025.
//

import Cocoa
import RFSupport

public class FONDEditor : AbstractEditor, ResourceEditor {

    public required init?(resource: Resource, manager: RFEditorManager) {
        <#code#>
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func saveResource(_ sender: Any) {
        <#code#>
    }
    
    public func revertResource(_ sender: Any) {
        <#code#>
    }
    
    public static var bundle: Bundle { .module }
    public static let supportedTypes = [
        "FOND",
    ]

    public let resource: Resource

    public override var windowNibName: NSNib.Name {
        "FONDEditorWindow"
    }




    
}

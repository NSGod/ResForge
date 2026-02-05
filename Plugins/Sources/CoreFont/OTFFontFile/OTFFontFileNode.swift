//
//  OTFFontFileNode.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation

/// abstract abstract superclass
open class OTFFontFileNode: NSObject {
    public weak var fontFile:      OTFFontFile!        // weak

    /// The following 3 properties must be overridden by any subclasses
    /// that intend for them to be used:

    /// size in bytes
    public var nodeLength:          UInt32 {
        fatalError("must be overridden by subclass")
    }

    /// size in bytes + size of associated child/sibling nodes
    public var totalNodeLength:     UInt32 {
        fatalError("must be overridden by subclass")
    }

    /// size in bytes
    public class var nodeLength:    UInt32 {
        fatalError("must be overridden by subclass")
    }

    public init(fontFile: OTFFontFile) throws {
        self.fontFile = fontFile
    }
}

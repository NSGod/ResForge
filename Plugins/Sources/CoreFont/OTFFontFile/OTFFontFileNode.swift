//
//  OTFFontFileNode.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport

/// abstract abstract superclass
open class OTFFontFileNode: NSObject {
    public weak var fontFile:      OTFFontFile!        // weak

    /// the following 2 properties must be overridden by any subclasses
    /// that intend for them to be called:
    public var nodeLength:         UInt32 = UInt32.max // size in bytes
    public var totalNodeLength:    UInt32 = UInt32.max // size in bytes + size of associated child/sibling nodes

    public init(fontFile: OTFFontFile) throws {
        self.fontFile = fontFile
    }
}

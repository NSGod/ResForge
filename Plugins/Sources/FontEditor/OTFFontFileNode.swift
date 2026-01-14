//
//  OTFFontFileNode.swift
//  FontEditor
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport

class OTFFontFileNode: NSObject {

    // the following 2 properties must be overridden by subclasses
    var nodeLength:         UInt32 = UInt32.max // size in bytes
    var totalNodeLength:    UInt32 = UInt32.max // size in bytes + size of associated child/sibling nodes

    weak var fontFile:      OTFFontFile?        // weak

    init(fontFile: OTFFontFile?) throws {
        self.fontFile = fontFile
    }
}

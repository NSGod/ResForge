//
//  FontTableNode.swift
//  FontEditor
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport

class FontTableNode: NSObject {
    // the following 2 properties must be overridden by subclasses
    var nodeLength:         UInt32 = UInt32.max
    var totalNodeLength:    UInt32 = UInt32.max
    
    weak var table:         FontTable?
}

//
//  FontTableNode.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport

open class FontTableNode: NSObject {
    // the following 2 properties must be overridden by subclasses
    public var nodeLength:         UInt32 = UInt32.max
    public var totalNodeLength:    UInt32 = UInt32.max

    public weak var table:         FontTable?
}

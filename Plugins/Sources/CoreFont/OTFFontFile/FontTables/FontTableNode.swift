//
//  FontTableNode.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport

open class FontTableNode: NSObject {
    public weak var table:         FontTable?

    /// the following 2 properties must be overridden by any subclasses who
    /// intend to have them called
    public var nodeLength:         UInt32 {
        fatalError("subclasses must override")
    }

    public var totalNodeLength:    UInt32 {
        fatalError("subclasses must override")
    }

    public init(_ reader: BinaryDataReader, offset: Int? = nil, table: FontTable? = nil) throws {
        super.init()
    }

    @objc public func compare(to other: FontTableNode) -> ComparisonResult {
        return .orderedSame
    }

}

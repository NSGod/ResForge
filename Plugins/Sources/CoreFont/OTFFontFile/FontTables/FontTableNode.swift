//
//  FontTableNode.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport

open class FontTableNode: NSObject, NSCopying {
    public weak var table:         FontTable!

    /// the following 2 properties must be overridden by any subclasses who
    /// intend to have them called
    public var nodeLength:         UInt32 {
        fatalError("subclasses must override")
    }

    public var totalNodeLength:    UInt32 {
        fatalError("subclasses must override")
    }

    public init(_ reader: BinaryDataReader, offset: Int? = nil, table: FontTable) throws {
        self.table = table
        super.init()
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy: FontTableNode = type(of: self).init() as! FontTableNode
        copy.table = self.table
        return copy
    }

    @objc public func compare(to other: FontTableNode) -> ComparisonResult {
        return .orderedSame
    }
}

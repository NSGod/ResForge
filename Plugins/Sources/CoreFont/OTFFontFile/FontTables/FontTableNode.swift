//
//  FontTableNode.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport

/// abstract superclass
open class FontTableNode: NSObject, NSCopying, DataHandleWriting {
    public weak var table:         FontTable!

    /// The following 3 properties must be overridden by any subclasses
    /// that intend for them to be used:

    /// size in bytes
    public var nodeLength:          UInt32 {
        fatalError("subclasses must override")
    }

    /// size in bytes + size of associated child/sibling nodes
    public var totalNodeLength:     UInt32 {
        fatalError("subclasses must override")
    }

    /// size in bytes
    public class var nodeLength:    UInt32 {    
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

    /// subclasses must override
    public func write(to handle: DataHandle, offset: Int? = nil) throws {
        fatalError("subclasses must override")
    }

    public func write(to dataHandle: DataHandle) throws {
        fatalError("subclasses must override")
    }
}

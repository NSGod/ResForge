//
//  Node.swift
//  CoreFont
//
//  Created by Mark Douma on 3/23/2026.
//

import Foundation
import RFSupport

public class Node: BinaryDataReadingNode, DataHandleWriting {
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

    /// `class` size in bytes
    public class var nodeLength:    UInt32 {
        fatalError("subclasses must override")
    }

    public required init(_ reader: BinaryDataReader? = nil, offset: Int? = nil) throws {

    }

    public func write(to handle: DataHandle, offset: Int? = nil) throws {
        fatalError("subclasses must override")
    }
}

//
//  ResourceNode.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/2/2026.
//

import Foundation
import CoreFont

public class ResourceNode: NSObject, DataHandleWriting {
    /// The following 3 properties must be overridden by any subclasses
    /// that intend for them to be used:

    /// size in bytes
    @objc public var nodeLength:        Int {
        fatalError("subclasses must override")
    }

    /// size in bytes + size of associated child/sibling nodes
    @objc public var totalNodeLength:   Int {
        fatalError("subclasses must override")
    }

    /// `class` size in bytes
    public class var nodeLength:        Int {
        fatalError("subclasses must override")
    }

    public func write(to dataHandle: DataHandle) throws {
        fatalError("subclasses must override")
    }
}

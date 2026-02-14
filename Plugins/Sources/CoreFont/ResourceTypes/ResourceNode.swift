//
//  ResourceNode.swift
//  CoreFont
//
//  Created by Mark Douma on 1/2/2026.
//

import Foundation

public class ResourceNode: NSObject, DataHandleWriting {
    /// The following 3 properties must be overridden by any subclasses
    /// that intend for them to be used:

    /// size in bytes
    @objc public var nodeLength:        Int {
        fatalError("\(type(of: self)) subclasses must override")
    }

    /// size in bytes + size of associated child/sibling nodes
    @objc public var totalNodeLength:   Int {
        fatalError("\(type(of: self)) subclasses must override")
    }

    /// `class` size in bytes
    public class var nodeLength:        Int {
        fatalError("\(type(of: self)) subclasses must override")
    }

    public func write(to dataHandle: DataHandle) throws {
        fatalError("\(type(of: self)) subclasses must override")
    }
}

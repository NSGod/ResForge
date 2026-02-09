//
//  OffsetTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=484

import Foundation
import RFSupport

final public class OffsetTable: ResourceNode {
    public var numberOfEntries:        Int16               // number of entries - 1
    @objc public var entries:          [Entry]

    @objc public override var totalNodeLength: Int {
        return MemoryLayout<Int16>.size + entries.count * Entry.nodeLength
    }

    public init(_ reader: BinaryDataReader) throws {
        numberOfEntries = try reader.read()
        entries = try (0...numberOfEntries).map { _ in try Entry(reader) }
        super.init()
    }
}

extension OffsetTable {

    final public class Entry: ResourceNode {
        @objc public var offsetOfTable: Int32    // number of bytes from START OF THE OFFSET TABLE to the start of the table

        public init(_ reader: BinaryDataReader) throws {
            offsetOfTable = try reader.read()
            super.init()
        }

        public override class var nodeLength: Int {
            return MemoryLayout<Int32>.size     // 4
        }
    }
}

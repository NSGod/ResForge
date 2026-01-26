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

    @objc public override var length:  Int {
        return MemoryLayout<Int16>.size + entries.count * Entry.length
    }

    public init(_ reader: BinaryDataReader) throws {
        numberOfEntries = try reader.read()
        entries = []
        for _ in 0...numberOfEntries {
            let entry: Entry = try Entry(reader)
            entries.append(entry)
        }
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

        public override class var length: Int {
            return MemoryLayout<Int32>.size // 4
        }
    }
}

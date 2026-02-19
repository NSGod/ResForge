//
//  OffsetTable.swift
//  CoreFont
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=484

import Foundation
import RFSupport

extension FOND {

    final public class OffsetTable: ResourceNode {
        public var numberOfEntries:        Int16               // number of entries - 1
        @objc public var entries:          [Entry]

        @objc public override var totalNodeLength: Int {
            return MemoryLayout<Int16>.size + entries.count * Entry.nodeLength
        }

        public var isStandard: Bool {
            return entries.count == 1 && entries[0].offsetOfTable == 6
        }

        /// create the standard entry for a Bounding Box Table
        public override init() {
            numberOfEntries = 0
            entries = [Entry()]
            super.init()
        }

        public init(_ reader: BinaryDataReader) throws {
            numberOfEntries = try reader.read()
            entries = try (0...numberOfEntries).map { _ in try Entry(reader) }
            super.init()
        }

        public override func write(to dataHandle: DataHandle) throws {
            numberOfEntries = Int16(entries.count - 1)
            dataHandle.write(numberOfEntries)
            try entries.forEach { try $0.write(to: dataHandle) }
        }

        public static func == (lhs: OffsetTable, rhs: OffsetTable) -> Bool {
            return lhs.numberOfEntries == rhs.numberOfEntries && lhs.entries == rhs.entries
        }
    }
}

extension FOND.OffsetTable {

    final public class Entry: ResourceNode {
        @objc public var offsetOfTable: Int32    // number of bytes from START OF THE OFFSET TABLE to the start of the table

        public override init() {
            offsetOfTable = 6
            super.init()
        }

        public init(_ reader: BinaryDataReader) throws {
            offsetOfTable = try reader.read()
            super.init()
        }

        public override class var nodeLength: Int {
            return MemoryLayout<Int32>.size     // 4
        }

        public override func write(to dataHandle: DataHandle) throws {
            dataHandle.write(offsetOfTable)
        }

        public static func == (lhs: Entry, rhs: Entry) -> Bool {
            return lhs.offsetOfTable == rhs.offsetOfTable
        }
    }
}

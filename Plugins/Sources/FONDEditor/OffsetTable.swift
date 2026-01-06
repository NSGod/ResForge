//
//  OffsetTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=484

import Foundation
import RFSupport

// will be displayed in UI, so need NSObject subclass?

final class OffsetTable: ResourceNode {
    var numberOfEntries:        Int16               // number of entries - 1
    @objc var entries:          [OffsetTableEntry]

    @objc override var length:  Int {
        return entries.count * OffsetTableEntry.length
    }

    init(_ reader: BinaryDataReader) throws {
        numberOfEntries = try reader.read()
        entries = []
        for _ in 0...numberOfEntries {
            let entry: OffsetTableEntry = try OffsetTableEntry(reader)
            entries.append(entry)
        }
        super.init()
    }
}


final class OffsetTableEntry: ResourceNode {
    @objc var offsetOfTable: Int32    // number of bytes from START OF THE OFFSET TABLE to the start of the table

    init(_ reader: BinaryDataReader) throws {
        offsetOfTable = try reader.read()
        super.init()
    }

    override class var length: Int {
        return MemoryLayout<Int32>.size // 4
    }
}

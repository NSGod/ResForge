//
//  OffsetTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=484

import Cocoa
import RFSupport

struct OffsetTable {
    var numberOfEntries:    Int16               // number of entries - 1
    var entries:            [OffsetTableEntry]
}

extension OffsetTable {
    init(_ reader: BinaryDataReader) throws {
        numberOfEntries = try reader.read()
        entries = []
        for _ in 0...numberOfEntries {
            let entry: OffsetTableEntry = try OffsetTableEntry(reader)
            entries.append(entry)
        }
    }
}

struct OffsetTableEntry {
    var offsetOfTable: Int32    // number of bytes from START OF THE OFFSET TABLE to the start of the table
}

extension OffsetTableEntry {
    init(_ reader: BinaryDataReader) throws {
        offsetOfTable = try reader.read()
    }
}

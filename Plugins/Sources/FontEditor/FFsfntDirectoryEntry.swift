//
//  FFsfntDirectoryEntry.swift
//  FontEditor
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport

class FFsfntDirectoryEntry: OTFFontFileNode, Comparable {
    var tableTag:               TableTag
    @objc var checksum:         UInt32
    @objc var offset:           UInt32         // offset from beginning of sfnt
    @objc var length:           UInt32         // actual length, not padded length

    // for display
    @objc var objcTableTag:     TableTag.RawValue { tableTag.rawValue }
    @objc var tableTagString:   String {
        tableTag.rawValue.fourCharString
    }

    var table:                  FontTable! {
        didSet {
            tableTag = table.tableTag
        }
    }

    static var nodeLength:  UInt32    = UInt32(MemoryLayout<UInt32>.size * 4) // 16

    init(_ reader: BinaryDataReader) throws {
        tableTag = TableTag(rawValue: try reader.read())
        checksum = try reader.read()
        offset = try reader.read()
        length = try reader.read()
        try super.init(fontFile: nil)
    }

    static func < (lhs: FFsfntDirectoryEntry, rhs: FFsfntDirectoryEntry) -> Bool {
        lhs.tableTag.rawValue < rhs.tableTag.rawValue
    }
}

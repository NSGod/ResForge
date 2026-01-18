//
//  OTFsfntDirectoryEntry.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport

final public class OTFsfntDirectoryEntry: OTFFontFileNode, Comparable {
    public var tableTag:               TableTag
    @objc public var checksum:         UInt32
    @objc public var offset:           UInt32         // offset from beginning of sfnt
    @objc public var length:           UInt32         // actual length, not padded length

    // for display
    @objc public var objcTableTag:     TableTag.RawValue { tableTag.rawValue }
    @objc public var tableTagString:   String {
        tableTag.rawValue.fourCharString
    }

    public var table:                  FontTable! {
        didSet {
            tableTag = table.tableTag
        }
    }

    public static var nodeLength:  UInt32    = UInt32(MemoryLayout<UInt32>.size * 4) // 16

    public init(_ reader: BinaryDataReader) throws {
        tableTag = TableTag(rawValue: try reader.read())
        checksum = try reader.read()
        offset = try reader.read()
        length = try reader.read()
        try super.init(fontFile: nil)
    }

    public static func < (lhs: OTFsfntDirectoryEntry, rhs: OTFsfntDirectoryEntry) -> Bool {
        lhs.tableTag.rawValue < rhs.tableTag.rawValue
    }
}

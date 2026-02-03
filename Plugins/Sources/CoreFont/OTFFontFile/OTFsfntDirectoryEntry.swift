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

    public var range: Range<UInt32> {
        return offset..<(offset + length)
    }

    public override class var nodeLength: UInt32 { UInt32(MemoryLayout<UInt32>.size * 4) }  // 16

    public init(_ reader: BinaryDataReader, fontFile: OTFFontFile) throws {
        tableTag = TableTag(rawValue: try reader.read())
        checksum = try reader.read()
        offset = try reader.read()
        length = try reader.read()
        try super.init(fontFile: fontFile)
    }

    public static func sortForParsing(lhs: OTFsfntDirectoryEntry, rhs: OTFsfntDirectoryEntry) -> Bool {
        let lhsIndex = Self.tagsToParsingOrder[lhs.tableTag]
        let rhsIndex = Self.tagsToParsingOrder[rhs.tableTag]
        if let lhsIndex, let rhsIndex {
            return lhsIndex < rhsIndex
        } else if lhsIndex != nil {
            return true
        } else if rhsIndex != nil {
            return false
        } else {
            return false
        }
    }

    public static func < (lhs: OTFsfntDirectoryEntry, rhs: OTFsfntDirectoryEntry) -> Bool {
        lhs.tableTag.rawValue < rhs.tableTag.rawValue
    }

    public static func == (lhs: OTFsfntDirectoryEntry, rhs: OTFsfntDirectoryEntry) -> Bool {
        return lhs.tableTag == rhs.tableTag
    }
    
    public override var description: String {
        "OTFsfntDirectoryEntry('\(tableTagString)', checksum: \(String(format: "0x%08x", checksum)), offset: \(offset), length: \(length))"
    }

    fileprivate static let tagsToParsingOrder: [TableTag: Int] = [
        .head: 0,
        .maxp: 1,
        .OS_2: 2,
        .post: 3,
        .name: 4,
        .hhea: 5,
        .hmtx: 6,
        .gasp: 7,
    ]
}

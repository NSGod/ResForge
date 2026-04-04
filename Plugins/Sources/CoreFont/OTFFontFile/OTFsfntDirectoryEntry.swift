//
//  OTFsfntDirectoryEntry.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport

public final class OTFsfntDirectoryEntry: OTFFontFileNode, DataHandleWriting, Comparable {
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

    public func write(to handle: DataHandle, offset: Int? = nil) throws {
        assert(offset == nil)
        handle.write(tableTag)
        handle.write(checksum)
        handle.write(self.offset)
        handle.write(length)
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
        lhs.tableTag < rhs.tableTag
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? OTFsfntDirectoryEntry else { return false }
        return tableTag == other.tableTag &&
        checksum == other.checksum &&
        offset == other.offset &&
        length == other.length
    }

    /// I believe this is what Swift does under the hood/bonnet, but
    /// better to make it explicitly clear
    public static func == (lhs: OTFsfntDirectoryEntry, rhs: OTFsfntDirectoryEntry) -> Bool {
        return lhs.isEqual(rhs)
    }

    public override var description: String {
        "OTFsfntDirectoryEntry('\(tableTagString)', checksum: \(String(format: "0x%08x", checksum)), offset: \(offset), length: \(length))"
    }

    fileprivate static let tagsToParsingOrder: [TableTag: Int] = [
        .head: 0,
        .bhed: 0,
        .maxp: 1,
        .OS_2: 2,
        .post: 3,
        .name: 4,
        .hhea: 5,
        .hmtx: 6,
        .cmap: 7,
        .gasp: 8,
        .bloc: 9,
        .EBLC: 9,
        .bdat: 10,
        .EBDT: 10,
    ]
}

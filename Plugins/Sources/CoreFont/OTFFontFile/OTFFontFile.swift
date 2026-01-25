//
//  OTFFontFile.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport
import OrderedCollections

final public class OTFFontFile: NSObject {
    @objc public var directory:     OTFsfntDirectory!

    public var tables:              OrderedSet<FontTable>

    private var data:               Data
    private let reader:             BinaryDataReader

    private var tableTagsToTables:  [TableTag: FontTable] = [:]
    // this is to help determine table indexes for display in UI:
    private var rangesToFontTables: [Range<UInt32>: FontTable] = [:]

    public init(_ data: Data) throws {
        self.data = data
        reader = BinaryDataReader(data)
        tables = OrderedSet()
        super.init()
        directory = try OTFsfntDirectory(reader, fontFile: self)
        // FIXME: load/font tables in a specified order
        var entries = directory.entries
        entries.sort {
            return OTFsfntDirectoryEntry.sortForParsing(lhs: $0, rhs: $1)
        }
        for entry in entries {
            let range = entry.range
            let tableData = try reader.subdata(with: range)
            let tableClass: FontTable.Type = FontTable.class(for: entry.tableTag).self
            let table = try tableClass.init(with: tableData, tableTag: entry.tableTag, fontFile: self)
            tables.append(table)
            rangesToFontTables[range] = table
            entry.table = table
        }
        // sort tables into the order they're found in the font for display
        tables.sort { table1, table2 in
            var offset1: UInt32 = 0
            var offset2: UInt32 = 0
            for (range, table) in rangesToFontTables {
                if table == table1 {
                    offset1 = range.lowerBound
                } else if table == table2 {
                    offset2 = range.lowerBound
                }
                if offset1 > 0 && offset2 > 0 { break }
            }
            // allow corrupt font to succeed w/o crashing
            // assert(offset1 != 0 && offset2 != 0)
            return offset1 < offset2
        }
    }

    public var headTable: FontTable_head? {
        return table(for: .head) as? FontTable_head
    }
    public var maxpTable: FontTable_maxp? {
        return table(for: .maxp) as? FontTable_maxp
    }
    public var postTable: FontTable_post? {
        return table(for: .post) as? FontTable_post
    }
    public var nameTable: FontTable_name? {
        return table(for: .name) as? FontTable_name
    }
    public func table(for tableTag: TableTag) -> FontTable? {
        return tableTagsToTables[tableTag]
    }

    private enum GlyphNameLookupType {
        case undetermined
        case post
        case cmap
        case CFF
        case TYP1
        case CID
    }
}

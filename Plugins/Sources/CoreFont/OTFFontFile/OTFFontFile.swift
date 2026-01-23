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
    @objc public var directory:     OTFsfntDirectory

    public var tables:              OrderedSet<FontTable>

    private var data:               Data
    private let reader:             BinaryDataReader

    var tableTagsToTables:          [TableTag: FontTable] = [:]

    public init(_ data: Data) throws {
        self.data = data
        reader = BinaryDataReader(data)
        directory = try OTFsfntDirectory(reader)
        tables = OrderedSet()
        for entry in directory.entries {
            let range = entry.offset..<entry.offset + entry.length
            let tableData = try reader.subdata(with: range)
            let tableClass: FontTable.Type = FontTable.class(for: entry.tableTag).self
            let table = try tableClass.init(with: tableData, tag: entry.tableTag)
            tables.append(table)
            entry.table = table
        }
        super.init()
        for entry in directory.entries {
            entry.fontFile = self
            entry.table.fontFile = self
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

//    private func table(for entry: OTFsfntDirectoryEntry) throws -> FontTable {
//        // FIXME: switch to Swift ranges
//        let tableRange = NSMakeRange(Int(entry.offset), Int(entry.length))
//
//
//
//    }

}

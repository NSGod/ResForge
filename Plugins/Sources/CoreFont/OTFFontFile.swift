//
//  OTFFontFile.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport
import OrderedCollections

public class OTFFontFile: NSObject {
    @objc public var directory:     OTFsfntDirectory

    public var tables:              OrderedSet<FontTable>

    private var data:               Data
    private let reader:             BinaryDataReader
//    private var

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

//    private func table(for entry: OTFsfntDirectoryEntry) throws -> FontTable {
//        // FIXME: switch to Swift ranges
//        let tableRange = NSMakeRange(Int(entry.offset), Int(entry.length))
//
//
//
//    }

}

//
//  OTFFontFile.swift
//  FontEditor
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport
import OrderedCollections

class OTFFontFile: NSObject {
    @objc var directory:    FFsfntDirectory

    var tables:             OrderedSet<FontTable>

    private var data:       Data
    private let dataHandle: BinaryDataReader
//    private var 

    init(_ data: Data) throws {
        self.data = data
        dataHandle = BinaryDataReader(data)
        directory = try FFsfntDirectory(dataHandle)
        tables = OrderedSet()
        for entry in directory.entries {
            let range = entry.offset..<entry.offset + entry.length
            let tableData = try dataHandle.subdata(with: range)
            let table: FontTable = try FontTable(with: tableData, tag:entry.tableTag)
            tables.append(table)
            entry.table = table
        }
        super.init()
    }

//    private func table(for entry: FFsfntDirectoryEntry) throws -> FontTable {
//        // FIXME: switch to Swift ranges
//        let tableRange = NSMakeRange(Int(entry.offset), Int(entry.length))
//
//
//
//    }

}

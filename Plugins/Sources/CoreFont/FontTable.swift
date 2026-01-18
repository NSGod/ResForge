//
//  FontTable.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport

open class FontTable: NSObject {
    public let tableTag:           TableTag

    public var tableData:          Data
    public var paddedTableData:    Data?

    public var tableLength:        Int { tableData.count }
    public var paddedTableLength:  Int { paddedTableData?.count ?? 0 }

    var tableDataHandle:    BinaryDataReader

    public init(with tableData: Data, tag: TableTag) throws {
        self.tableData = tableData
        tableTag = tag
        tableDataHandle = BinaryDataReader(tableData)
        super.init()
    }
}

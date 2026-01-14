//
//  FontTable.swift
//  FontEditor
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport

class FontTable: NSObject {
    let tableTag:           TableTag

    var tableData:          Data
    var paddedTableData:    Data?

    var tableLength:        Int { tableData.count }
    var paddedTableLength:  Int { paddedTableData?.count ?? 0 }

    var tableDataHandle:    BinaryDataReader

    init(with tableData: Data, tag: TableTag) throws {
        self.tableData = tableData
        tableTag = tag
        tableDataHandle = BinaryDataReader(tableData)
        super.init()
    }

}

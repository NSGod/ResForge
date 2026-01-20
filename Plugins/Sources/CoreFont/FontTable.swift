//
//  FontTable.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport

open class FontTable: NSObject {
    public weak var fontFile:       OTFFontFile?

    public let tableTag:            TableTag

    public var tableData:           Data
    public var paddedTableData:     Data?

    public var tableLength:         Int { tableData.count }
    public var paddedTableLength:   Int { paddedTableData?.count ?? 0 }

    var reader:    BinaryDataReader

    public required init(with tableData: Data, tag: TableTag) throws {
        self.tableData = tableData
        tableTag = tag
        reader = BinaryDataReader(tableData)
        super.init()
    }

    public static func `class`(for tableTag: TableTag) -> FontTable.Type {
//        if tableTag == .OS_2 { return FontTable_OS_2.self }
//        if tableTag == .CID_ { return FontTable_CID.self }
//        if tableTag == .cvt_ { return FontTable_cvt.self }
//        if tableTag == .CFF_ { return FontTable_CFF.self }
        if let theClass: FontTable.Type = NSClassFromString("CoreFont.FontTable_\(tableTag.fourCharString)") as? FontTable.Type {
            return theClass
            // if class is Nil, try byte-swapping the table tag to see if it's wrong in the font (i.e. 'SOPG' instead of 'GPOS')
        } else if let theClass: FontTable.Type = NSClassFromString("CoreFont.FontTable_\(tableTag.byteSwapped.fourCharString)") as? FontTable.Type {
            return theClass
        }
        return FontTable.self
    }
}

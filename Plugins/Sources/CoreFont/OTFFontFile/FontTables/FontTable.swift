//
//  FontTable.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport

public enum FontTableError: LocalizedError {
    case unknownVersion
    case parseError
}

/// abstract superclass
open class FontTable: OTFFontFileNode {
    public let tableTag:            TableTag

    public var tableData:           Data
    public var paddedTableData:     Data {
        var paddedData = tableData
        paddedData.count = (paddedData.count + 3 ) & -4
        return paddedData
    }

    public var tableLength:         Int { tableData.count }
    public var paddedTableLength:   Int { paddedTableData.count }

    public var calculatedChecksum: UInt32 {
        let tableLongs: [UInt32] = paddedTableData.withUnsafeBytes{ rawBuffer in
            return rawBuffer.bindMemory(to: UInt32.self).map(\.bigEndian)
        }
        var calcChecksum: UInt32 = 0
        for long in tableLongs {
            calcChecksum &+= long
        }
        return calcChecksum
    }

    var reader:    BinaryDataReader

    public required init(with tableData: Data, tag: TableTag) throws {
        self.tableData = tableData
        tableTag = tag
        reader = BinaryDataReader(tableData)
        try super.init()
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

    public func table(for tableTag: TableTag) -> FontTable? {
        return fontFile?.table(for: tableTag)
    }

    public var headTable: FontTable_head? { table(for: .head) as? FontTable_head }
    public var maxpTable: FontTable_maxp? { table(for: .maxp) as? FontTable_maxp }
    public var postTable: FontTable_post? { table(for: .post) as? FontTable_post }
    public var nameTable: FontTable_name? { table(for: .name) as? FontTable_name }

}

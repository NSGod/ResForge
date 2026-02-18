//
//  FontTable_cvt.swift
//  CoreFont
//
//  Created by Mark Douma on 2/17/2026.
//

import Foundation
import RFSupport

/*
 It contains an array of Int16s that can be accessed by instructions. The 'cvt '
 table is used to tie together certain font features when their values are sufficiently
 close to the table value.
 */

final public class FontTable_cvt: FontTable {
    @objc public var controlValues:     [Int16]

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        controlValues = []
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        while reader.bytesRemaining > 0 {
            let value: Int16 = try reader.read()
            controlValues.append(value)
        }
    }

    override func write() throws {
        controlValues.forEach { dataHandle.write($0) }
    }
}

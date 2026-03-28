//
//  FontTable_bdat.swift
//  CoreFont
//
//  Created by Mark Douma on 3/23/2026.
//

import Foundation
import RFSupport

/// `REQUIRES`:
/// `DEPENDS ON`:
/// `DISPLAY DEPENDS ON`:

public class FontTable_bdat: FontTable {

    @objc public enum Version: Fixed {
        case default2_0 = 0x00020000

        public init?(rawValue: Fixed) {
            switch rawValue {
                case 0x00020000: self = .default2_0
                default:
                    NSLog("\(type(of: self)).\(#function) *** WARNING: unknown version: \(String(format: "0x%08X", rawValue)); using .default2_0")
                    self = .default2_0
            }
        }
    }

    // MARK: -
    @objc public var version:           Version = .default2_0

    public var bitmapStrikes:           [BitmapStrike] = []

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        version = try reader.read()
        guard let blocTable = fontFile.blocTable else {
            throw FontTableError.parseError("could not find bloc table")
        }
        for size in blocTable.sizes {
            let strike = try BitmapStrike(reader, sizeTable: size)
            bitmapStrikes.append(strike)
        }
    }
}

/// Microsoft equivalent to Apple's `bdat` table
/// Different name but identical function
public final class FontTable_EBDT: FontTable_bdat {

}

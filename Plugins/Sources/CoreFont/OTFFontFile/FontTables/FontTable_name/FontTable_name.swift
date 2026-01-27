//
//  FontTable_name.swift
//  CoreFont
//
//  Created by Mark Douma on 1/20/2026.
//

import Foundation
import RFSupport

/// `REQUIRES`:
/// `DEPENDS ON`:
/// `DISPLAY DEPENDS ON`:

final public class FontTable_name: FontTable {
    @objc public enum Format: UInt16 {
        case format0    = 0
        case format1    = 1     // not supported by Apple
    }

    @objc public var format:                Format = .format0

    public var count:                       UInt16 = 0      // number of name records
    public var stringOffset:                UInt16 = 0      // offset (from start of table) to string storage
    @objc public var nameRecords:           [NameRecord] = []

    public var langTagCount:                UInt16 = 0      // format 1 only
    @objc public var languageTagRecords:    [LanguageTagRecord]?

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        self.parseState = .parsing
        let format: UInt16 = try reader.read()
        guard let format = Format(rawValue: format) else {
            throw FontTableError.unknownFormat("Unknown 'name' table format (\(format))")
        }
        self.format = format
        count = try reader.read()
        stringOffset = try reader.read()
        for _ in 0..<self.count {
            let nRecord = try NameRecord(reader, stringOffset: stringOffset, table: self)
            nameRecords.append(nRecord)
        }
        if format == .format1 {
            langTagCount = try reader.read()
            if langTagCount > 0 {
                languageTagRecords = []
                for _ in 0..<langTagCount {
                    let ltr = try LanguageTagRecord(reader, stringOffset: stringOffset, table: self)
                    languageTagRecords?.append(ltr)
                }
            }
        }
        self.parseState = .parsed
    }
}

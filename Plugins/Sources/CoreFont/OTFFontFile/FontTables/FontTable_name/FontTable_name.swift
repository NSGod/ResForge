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

	// MARK: -
    @objc public var format:                Format = .format0

    public var count:                       UInt16 = 0      // number of name records
    public var stringOffset:                UInt16 = 0      // offset (from start of table) to string storage
    @objc public var nameRecords:           [NameRecord] = []

    public var langTagCount:                UInt16 = 0      // format 1 only
    @objc public var languageTagRecords:    [LanguageTagRecord]?

	// MARK: -
    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        let format: UInt16 = try reader.read()
        guard let format = Format(rawValue: format) else {
            throw FontTableError.unknownFormat("Unknown 'name' table format (\(format))")
        }
        self.format = format
        count = try reader.read()
        stringOffset = try reader.read()
        nameRecords = try (0..<count).map { _ in try NameRecord(reader, stringOffset: stringOffset, table: self) }
        if format == .format1 {
            langTagCount = try reader.read()
            if langTagCount > 0 {
                languageTagRecords = try (0..<langTagCount).map { _ in try LanguageTagRecord(reader, stringOffset: stringOffset, table: self) }
            }
        }
    }

    override func prepareToWrite() throws {
        // FIXME: add support for language tags?
        format = .format0
        nameRecords.sort(by: <)
        count = UInt16(nameRecords.count)
        var offset: UInt16 = UInt16(MemoryLayout<UInt16>.size) * 3 + count * UInt16(NameRecord.nodeLength)
        stringOffset = offset
        struct HashName: Hashable {
            let hash:   Int
            let nameID: FontNameID
        }
        var hashNamesToRecords: [HashName: NameRecord] = [:]
        /// Allow shared string storage among records that share the same `fontNameID` and
        /// where the data is the same. For example, a Unicode platform entry for `fontNameID` of `.postscript`
        /// has a value of "Helvetica" in UTF-16BE. A Windows platform entry for `fontNameID` of `.postscript`
        /// (which will also be in UTF16-BE) that is also equal to "Helvetica" can simply reference the
        /// same string storage that the Unicode entry does.
        for nameRecord in nameRecords {
            let hashName = HashName(hash: nameRecord.data.hashValue, nameID: nameRecord.nameID)
            if let existingRecord = hashNamesToRecords[hashName] {
                nameRecord.offset = existingRecord.offset
                nameRecord.data = nil
            } else {
                nameRecord.offset = offset - stringOffset
                offset += nameRecord.length
                hashNamesToRecords[hashName] = nameRecord
            }
        }
    }

    override func write() throws {
        dataHandle.write(format)
        dataHandle.write(count)
        dataHandle.write(stringOffset)
        try nameRecords.forEach{ try $0.write(to: dataHandle, stringOffset: stringOffset) }
        // FIXME: add support for format 1?
    }

    // FIXME: something better to allow preference of English?
    public func nameFor(name: FontNameID, platform: PlatformID = .any, encoding: EncodingID = .any, language: LanguageID = .any) -> String? {
        return recordFor(name: name, platform: platform, encoding: encoding, language: language)?.value
    }

    /// O(n)
    public func recordFor(name: FontNameID, platform: PlatformID = .any, encoding: EncodingID = .any, language: LanguageID = .any) -> NameRecord? {
        let record = nameRecords.first(where: {
            $0.nameID == name &&
            ($0.platformID == platform || platform == .any) &&
            ($0.encodingID == encoding || encoding == .any) &&
            ($0.languageID == language || language == .any)
        })
        return record
    }
}

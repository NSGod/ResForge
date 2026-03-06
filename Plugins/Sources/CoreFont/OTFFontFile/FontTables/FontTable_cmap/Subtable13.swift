//
//  Subtable13.swift
//  CoreFont
//
//  Created by Mark Douma on 2/23/2026.
//

import Foundation
import RFSupport

extension FontTable_cmap {

    /// this subtable format is primarily used for last-resort-type fonts
    public final class Subtable13: Subtable {
        // public var format:           Format          // UInt16
        public var reserved:            UInt16 = 0      // padding
        public var length:              UInt32 = 0
        // public var languageID:       LanguageID      // UInt32 variant
        public var numGroups:           UInt32 = 0
        public var groups:              [Group] = []    // [numGroups]
        
        public required init(_ reader: BinaryDataReader?, offset: Int? = nil, encoding: Encoding, table: FontTable) throws {
            try super.init(reader, offset: offset, encoding: encoding, table: table)
            if let reader {
                reserved = try reader.read()
                length = try reader.read()
                languageID = try LanguageID.languageIDWith(platformID: encoding.platformID, extendedLanguageID: try reader.read())
                numGroups = try reader.read()
                groups = try (0..<numGroups).map { _ in try Group(reader, table: table) }
                var charCodesToGlyphIDs: [CharCode32: GlyphID32] = [:]
                for group in groups {
                    /// unlike in format 12 where we increment the glyphID, here we don't (which is why it works for last resort fonts)
                    for charCode in group.startCharCode...group.endCharCode {
                        if charCode != 0xffff && group.glyphID != 0 {
                            charCodesToGlyphIDs[charCode] = group.glyphID
                        }
                    }
                }
                self.charCodesToGlyphIDs = charCodesToGlyphIDs
            }
        }

        public override func write(to dataHandle: DataHandle, offset: Int? = nil) throws {
            guard let offset else { throw FontTableError.parseError("No offset") }
            dataHandle.pushSavedOffset()
            dataHandle.seek(to: offset)
            try super.write(to: dataHandle, offset: offset)
            dataHandle.write(reserved)
            dataHandle.write(length)
            dataHandle.write(languageID.extendedRawValue)
            dataHandle.write(numGroups)
            try groups.forEach { try $0.write(to: dataHandle) }
            dataHandle.popAndSeekToSavedOffset()
        }
    }
}

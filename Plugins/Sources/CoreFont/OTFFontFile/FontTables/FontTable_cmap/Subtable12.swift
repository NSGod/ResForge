//
//  Subtable12.swift
//  CoreFont
//
//  Created by Mark Douma on 2/23/2026.
//

import Foundation
import RFSupport

extension FontTable_cmap {

    public final class Subtable12: Subtable {
        // public var format:           Format          // UInt16
        public var reserved:            UInt16 = 0      // padding
        public var length:              UInt32 = 0
        // public var languageID:       LanguageID      // UInt32 variant
        public var numGroups:           UInt32 = 0
        public var groups:              [Group] = []    // [numGroups]

        public required init(_ reader: BinaryDataReader?, offset: Int? = nil, encoding: FontTable_cmap.Encoding, table: FontTable) throws {
            try super.init(reader, offset: offset, encoding: encoding, table: table)
            if let reader {
                reserved = try reader.read()
                length = try reader.read()
                languageID = try LanguageID.languageIDWith(platformID: encoding.platformID, extendedLanguageID: try reader.read())
                numGroups = try reader.read()
                groups = try (0..<numGroups).map { _ in try Group(reader, table: table) }
                var charCodesToGlyphIDs: [CharCode32: GlyphID32] = [:]
                for group in groups {
                    var glyphID: GlyphID32 = 0
                    for charCode in group.startCharCode...group.endCharCode {
                        if charCode != 0xffff && glyphID != 0 {
                            charCodesToGlyphIDs[charCode] = glyphID
                        }
                        glyphID += 1
                    }
                }
                self.charCodesToGlyphIDs = charCodesToGlyphIDs
            }
        }

        public override func write(to handle: DataHandle, offset: Int? = nil) throws {
            assert(offset != nil)
            guard let offset else { throw FontTableError.writeError("No offset") }
            handle.pushSavedOffset()
            handle.seek(to: offset)
            try super.write(to: handle, offset: offset)
            handle.write(reserved)
            handle.write(length)
            handle.write(languageID.extendedRawValue)   // UInt32
            handle.write(numGroups)
            try groups.forEach { try $0.write(to: handle) }
            handle.popAndSeekToSavedOffset()
        }
    }
}

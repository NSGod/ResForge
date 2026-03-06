//
//  Subtable0.swift
//  CoreFont
//
//  Created by Mark Douma on 2/23/2026.
//

import Foundation
import RFSupport

extension FontTable_cmap {

    public final class Subtable0: Subtable {
        // public var format:           Format
        public var length:              UInt16 = 0
        // public var languageID:       LanguageID      // one-based for Mac; should be 0 for all other platforms
        public var glyphIDs:            [UInt8] = []    // UInt8[256]

        public required init(_ reader: BinaryDataReader?, offset: Int? = nil, encoding: Encoding, table: FontTable) throws {
            try super.init(reader, offset: offset, encoding: encoding, table: table)
            if let reader {
                length = try reader.read()
                languageID = try LanguageID.languageIDWith(platformID: encoding.platformID, languageID: try reader.read())
                var charCodesToGlyphIDs: [CharCode32: GlyphID32] = [:]
                glyphIDs = try (0...UInt8.max).map { _ in try reader.read() }
                for (i, glyphID) in glyphIDs.enumerated() {
                    charCodesToGlyphIDs[CharCode32(i)] = GlyphID32(glyphID)
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
            handle.write(length)
            handle.write(languageID.rawValue)   // UInt16
            glyphIDs.forEach { handle.write($0) }
            handle.popAndSeekToSavedOffset()
        }

        public override var nodeLength: UInt32 {
            return 262
        }
    }
}

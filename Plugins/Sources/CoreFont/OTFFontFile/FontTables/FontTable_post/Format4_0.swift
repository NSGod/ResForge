//
//  Format4_0.swift
//  CoreFont
//
//  Created by Mark Douma on 1/21/2026.
//

import Foundation
import RFSupport

public extension FontTable_post {

    final class Format4_0: Format {
        /// "The 'post' table header is followed by an array of UInt16 values.
        ///  An entry for every glyph is required. The index into the array is the glyph index.
        ///  The data in the array is the character code that maps to that glyph,
        ///  or `0xFFFF` if there is no associated character code for that glyph."
        var codes:                  [CharCode16] = []

        public required init(_ reader: BinaryDataReader, offset: Int? = nil, table: FontTable) throws {
            try super.init(reader, offset: offset, table: table)
            var numGlyphs = table.fontNumGlyphs
            /// have run into some fonts with fewer bytes than they should have
            numGlyphs = min(numGlyphs, reader.bytesRemaining/MemoryLayout<UInt16>.size)
            codes = try (0..<numGlyphs).map { _ in try reader.read() }
            glyphEntries = (0..<numGlyphs).map { GlyphEntry(glyphID: GlyphID($0), code: codes[$0]) }
            glyphEntries.forEach { glyphIDsToEntries[GlyphID32($0.glyphID)] = $0 }
        }

        public override func write(to handle: DataHandle, offset: Int? = nil) throws {
            assert(offset == nil)
            codes.forEach { handle.write($0) }
        }
    }
}

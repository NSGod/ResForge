//
//  GlyphNameEncodingSubtable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=493

import Foundation
import RFSupport

/*   The glyph-name encoding subtable of the style-mapping table allows the
     font family designer to map 8-bit character codes to PostScript glyph names.
     This subtable is required when the font family character set is not
     the Standard Roman character set or the standard Adobe character set.
     Each entry in this table is a Pascal string, the first byte of which is
     the character code that is being mapped, and the remaining bytes of which
     specify the PostScript glyph name.

     There is no data type defined to represent the glyph-encoding subtable. The
     elements of this subtable are as follows:
        ■ String count. An integer value that specifies the number of entries in the encoding subtable.
        ■ Strings. A variable length array of Pascal strings. The first byte of each string is an eight-bit
            character code, and the remaining bytes are the name of a PostScript glyph.
            This section beginning on page 4-105, provides an example of using this table.
 */

struct GlyphNameEncodingSubtable {
    var numberOfEntries:        Int16               // actual number of entries

    var charCodesToGlyphNames:  [CharCode: String] = [:]

    private(set)var length:     Int
}

extension GlyphNameEncodingSubtable {
    
    init(_ reader: BinaryDataReader) throws {
        let before = reader.position
        numberOfEntries = try reader.read()
        for _ in 0..<numberOfEntries {
            let charCode: CharCode = try reader.read()
            let glyphName = try reader.readPString()
            charCodesToGlyphNames[charCode] = glyphName
        }
        length = before - reader.position
    }

    func glyphName(for charCode: CharCode) -> String? {
        return charCodesToGlyphNames[charCode]
    }

}

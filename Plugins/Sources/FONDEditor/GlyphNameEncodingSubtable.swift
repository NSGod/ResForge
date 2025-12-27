//
//  GlyphNameEncodingSubtable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//

import Cocoa
import RFSupport

/*   The glyph-name encoding subtable of the style-mapping table allows the
     font family designer to map 8-bit character codes to PostScript glyph names.
     This subtable is required when the font family character set is not
     the Standard Roman character set or the standard Adobe character set.
     Each entry in this table is a Pascal string, the first byte of which is
     the character code that is being mapped, and the remaining bytes of which
     specify the PostScript glyph name.
 */

struct GlyphNameEncodingSubtable {
    var numberOfEntries:            Int16

    var charCodesToGlyphNames:      [CharCode: String]

}

extension GlyphNameEncodingSubtable {
    init(_ reader: BinaryDataReader) throws {


    }

}

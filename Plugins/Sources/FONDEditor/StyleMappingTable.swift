//
//  StyleMappingTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//

import Cocoa
import RFSupport

/*        Style-mapping table : 58 bytes        */
struct StyleMappingTable {
    var fontClass:                  FontClass
    var offset:                     Int32       /* offset from the start of this table to the glyph-name-encoding subtable component */
    var reserved:                   Int32
    var indexes:                    [UInt8]     // [48]

    var fontNameSuffixSubtable:     FontNameSuffixSubtable?
    var glyphNameEncodingSubtable:  GlyphNameEncodingSubtable?
}

extension StyleMappingTable {

}

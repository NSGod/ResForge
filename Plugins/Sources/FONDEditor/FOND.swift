//
//  FOND.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/22/2025.
//

import Cocoa
import RFSupport

// FontFamilyRecord is the first 52 bytes of the FOND

struct FOND {
    var ffFlags:        FontFamilyFlags     /* flags for family */
    var famID:          ResID               /* family ID number */
    var firstChar:      Int16               /* ASCII code of 1st character */
    var lastChar:       Int16               /* ASCII code of last character */
    var ascent:         Fixed4Dot12         /* maximum ascent for 1pt font;     Fixed 4.12 */
    var descent:        Fixed4Dot12         /* maximum descent for 1pt font;    Fixed 4.12 */
    var leading:        Fixed4Dot12         /* maximum leading for 1pt font;    Fixed 4.12 */
    var widMax:         Fixed4Dot12         /* maximum width for 1pt font;      Fixed 4.12 */

    var wTabOff:        Int32               /* offset to family glyph-width table from beginning of font family
                                                resource to beginning of table, in bytes */
    var kernOff:        Int32               /* offset to kerning table from beginning of font family resource to
                                                beginning of table, in bytes */
    var styleOff:       Int32               /* offset to style mapping table from beginning of font family
                                                resource to beginning of table, in bytes */

    var ewSPlain:       Fixed4Dot12         /* style property info; extra widths for different styles */
    var ewSBold:        Fixed4Dot12
    var ewSItalic:      Fixed4Dot12
    var ewSUnderline:   Fixed4Dot12
    var ewSOutline:     Fixed4Dot12
    var ewSShadow:      Fixed4Dot12
    var ewSCondensed:   Fixed4Dot12
    var ewSExtended:    Fixed4Dot12
    var ewSUnused:      Fixed4Dot12

    var intl0:          Int16               /* for international use */
    var intl1:          Int16               /* for international use */

    var ffVersion:      FontFamilyVersion   /* version number */

    var fontAssociationTable:   FontAssociationTable

    var offsetTable:            OffsetTable?
    var boundingBoxTable:       BoundingBoxTable?
    var widthTable:             WidthTable?
    var styleMappingTable:      StyleMappingTable?
    var kernTable:              KernTable?
}

extension FOND {
    init(_ reader: BinaryDataReader) throws {


    }
}

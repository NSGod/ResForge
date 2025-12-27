//
//  FOND.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/22/2025.
//

import Cocoa
import RFSupport

enum FONDError: LocalizedError {
    case noFontAssociationTableEntries
    case fontAssociationTableEntriesInvalid
    case fontAssociationTableEntriesNotAscending
    case fontAssociationTableEntriesRefSameFont
    case firstResourceNameIsZeroLength
    case noName
    case invalidCharRange
    case invalidWidthTableOffset
    case invalidKerningTableOffset
    case invalidStyleMappingTableOffset
    case lengthTooShort
    case offsetTableUsability
    case boundingBoxTableUsability
    case widthTableUsability
    case styleMappingTableUsability
    case fontNameSuffixSubtableUsability
    case glyphNameTableUsability
    case kernTableUsability
}

struct FOND {
    // FontFamilyRecord is the first 52 bytes of the FOND
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

    var countOfFontAssociationTableEntries: Int {
        return fontAssociationTable.entries.count
    }

    // lazy data structures
    var offsetTable:            OffsetTable?
    var boundingBoxTable:       BoundingBoxTable?
    var widthTable:             WidthTable?
    var styleMappingTable:      StyleMappingTable?
    var kernTable:              KernTable?

    enum TableOffsetType {
        case offsetTable
        case bboxTable
        case widthTable
        case styleTable
        case kernTable
    }

    private var offsetTypesToRanges: [TableOffsetType: Range<Int>]
    private var needsRepair: Bool
}

extension FOND {
    init(_ reader: BinaryDataReader) throws {
        // FIXME: deal with FOND w/ no name error
        ffFlags         = try reader.read()
        famID           = try reader.read()
        firstChar       = try reader.read()
        lastChar        = try reader.read()
        ascent          = try reader.read()
        descent         = try reader.read()
        leading         = try reader.read()
        widMax          = try reader.read()
        wTabOff         = try reader.read()
        kernOff         = try reader.read()
        styleOff        = try reader.read()

        ewSPlain        = try reader.read()
        ewSBold         = try reader.read()
        ewSItalic       = try reader.read()
        ewSUnderline    = try reader.read()
        ewSOutline      = try reader.read()
        ewSShadow       = try reader.read()
        ewSCondensed    = try reader.read()
        ewSExtended     = try reader.read()
        ewSUnused       = try reader.read()

        intl0           = try reader.read()
        intl1           = try reader.read()
        ffVersion       = try reader.read()

        
    }

    mutating func add(_ fontAssociationTableEntry: FontAssociationTableEntry) throws {

    }

    mutating func remove(_ fontAssociationTableEntry: FontAssociationTableEntry) throws {

    }

    func unitsPerEm(for fontStyle: MacFontStyle) -> UnitsPerEm {

    }

    func glyphName(for charCode: CharCode) -> String? {

        return nil
    }
}

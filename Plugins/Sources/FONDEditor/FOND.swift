//
//  FOND.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/22/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=478

import Foundation
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
    static let fontFamilyRecordLength   = 52

    // FontFamilyRecord is the first 52 bytes of the FOND
    var ffFlags:        FontFamilyFlags     // flags for family
    var famID:          ResID               // family ID number
    var firstChar:      Int16               // ASCII code of 1st character
    var lastChar:       Int16               // ASCII code of last character
    var ascent:         Fixed4Dot12         // maximum ascent for 1pt font;     Fixed 4.12
    var descent:        Fixed4Dot12         // maximum descent for 1pt font;    Fixed 4.12
    var leading:        Fixed4Dot12         // maximum leading for 1pt font;    Fixed 4.12
    var widMax:         Fixed4Dot12         // maximum width for 1pt font;      Fixed 4.12

    var wTabOff:        Int32               /* offset to family glyph-width table from beginning of font family
                                                resource to beginning of table, in bytes */
    var kernOff:        Int32               /* offset to kerning table from beginning of font family resource to
                                                beginning of table, in bytes */
    var styleOff:       Int32               /* offset to style mapping table from beginning of font family
                                                resource to beginning of table, in bytes */

    var ewSPlain:       Fixed4Dot12         // style property info; extra widths for different styles
    var ewSBold:        Fixed4Dot12
    var ewSItalic:      Fixed4Dot12
    var ewSUnderline:   Fixed4Dot12
    var ewSOutline:     Fixed4Dot12
    var ewSShadow:      Fixed4Dot12
    var ewSCondensed:   Fixed4Dot12
    var ewSExtended:    Fixed4Dot12
    var ewSUnused:      Fixed4Dot12

    var intl0:          Int16               // for international use
    var intl1:          Int16               // for international use

    var ffVersion:      FontFamilyVersion   // version number

    var fontAssociationTable:   FontAssociationTable

    var countOfFontAssociationTableEntries: Int {
        return fontAssociationTable.entries.count
    }

    var remainingTableData:     Data

    // MARK: ideally, these would be lazy data structures,
    // though I'm not sure how to do that in Swift and given the current BinaryDataReader design
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

    private var offsetTypesToRanges:    [TableOffsetType: NSRange]
    private var offsetsCalculated:      Bool
    private var needsRepair:            Bool   // If this FOND resource's resourceID doesn't match the famID, we need to update the famID
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

        // FIXME: make sure famID == this FOND's resource ID, otherwise repair it
        // FIXME: add validation/error-checking here

        fontAssociationTable = try FontAssociationTable(reader)

        reader.pushSavedPosition()
        remainingTableData = try reader.readData(length: reader.bytesRemaining)
        reader.popPosition()

        try calculateOffsetsIfNeeded(reader)

        // can only have a Bounding Box table if we have an offset table to specify its offset
        if let offsetTable = offsetTable {
            // might have a bounding box table
            let offsetTableOffset = Self.fontFamilyRecordLength + fontAssociationTable.length
            try reader.pushPosition(offsetTableOffset + Int(offsetTable.entries[0].offsetOfTable))
            boundingBoxTable = try BoundingBoxTable(reader)
            reader.popPosition()
        }

        // Width table
        if wTabOff > 0 {
            try reader.pushPosition(Int(wTabOff))
            widthTable = try WidthTable(reader, fond:self)
            reader.popPosition()
        }

        // Kern table
        if kernOff > 0 {
            guard let kernRange = offsetTypesToRanges[.kernTable] else {
                NSLog("\(type(of: self)).\(#function)() *** ERROR: could not determine kernTableRange!")
            }
            try reader.pushPosition(Int(kernOff))
            kernTable = try KernTable(reader)
            reader.popPosition()
        }

        // StyleMapping table
        if styleOff > 0 {
            if let styleMappingRange = offsetTypesToRanges[.styleTable] {
                try reader.pushPosition(Int(styleOff))
                styleMappingTable = try StyleMappingTable(reader, range:styleMappingRange)
                reader.popPosition()
            } else {
                NSLog("\(type(of: self)).\(#function)() *** ERROR: could not determine styleMappingRange!!")
            }
        }

    }

    private mutating func calculateOffsetsIfNeeded(_ reader: BinaryDataReader) throws {
        if offsetsCalculated == true { return }
        var offsetsToOffsetTypes: [Int32: TableOffsetType] = [:]
        if wTabOff > 0 { offsetsToOffsetTypes[wTabOff] = .widthTable }
        if styleOff > 0 { offsetsToOffsetTypes[styleOff] = .styleTable }
        if kernOff > 0 { offsetsToOffsetTypes[kernOff] = .kernTable }
        var currentOffset: Int32 = Int32(Self.fontFamilyRecordLength) + Int32(fontAssociationTable.length)
        var orderedOffsets: [Int32] = Array(offsetsToOffsetTypes.keys)
        orderedOffsets.sort()
        if (orderedOffsets.count == 0 && currentOffset < reader.data.count) ||
            (orderedOffsets.count > 0 && currentOffset < orderedOffsets[0] && currentOffset < reader.data.count) {
            // may have an Offset table
            try reader.setPosition(Int(currentOffset))
            offsetTable = try OffsetTable(reader)
        }
        for i in 0..<orderedOffsets.count {
            let firstOffset = orderedOffsets[i]
            let secondOffset = (i == orderedOffsets.count - 1 ? Int32(reader.data.count) : orderedOffsets[i + 1])
            let range = NSMakeRange(Int(firstOffset), Int(secondOffset - firstOffset))
            // FIXME: I don't know what's going on here with the ! being necessary:
            offsetTypesToRanges[offsetsToOffsetTypes[firstOffset]!] = range
        }
        offsetsCalculated = true
    }

    mutating func add(_ fontAssociationTableEntry: FontAssociationTableEntry) throws {

    }

    mutating func remove(_ fontAssociationTableEntry: FontAssociationTableEntry) throws {

    }

    mutating func shiftOffsetsAndRanges(by deltaLength: Int) {
        // the table offsets could be empty (== 0) so check before modifying their values
        if wTabOff > 0 {

        }

        if kernOff > 0 {

        }

        if styleOff > 0 {

        }
    }

    func unitsPerEm(for fontStyle: MacFontStyle) -> UnitsPerEm {
        for entry in fontAssociationTable.entries {
            if entry.fontStyle == fontStyle && entry.fontPointSize == 0 {
                return .trueTypeStandard
            }
        }
        return .postScriptStandard
    }

    func glyphName(for charCode: CharCode) -> String? {

        return nil
    }
}

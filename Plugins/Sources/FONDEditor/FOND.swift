//
//  FOND.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/22/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=478

import Foundation
import RFSupport

class FOND: NSObject {
    struct FontFamilyRecord {
        static let length = 52
    }

    // FontFamilyRecord is the first 52 bytes of the FOND
    var ffFlags:                FontFamilyFlags     // flags for family
    @objc var famID:            ResID               // family ID number
    @objc var firstChar:        Int16               // ASCII code of 1st character
    @objc var lastChar:         Int16               // ASCII code of last character
    @objc var ascent:           Fixed4Dot12         // maximum ascent for 1pt font;  Fixed 4.12
    @objc var descent:          Fixed4Dot12         // maximum descent for 1pt font; Fixed 4.12
    @objc var leading:          Fixed4Dot12         // maximum leading for 1pt font; Fixed 4.12
    @objc var widMax:           Fixed4Dot12         // maximum width for 1pt font;   Fixed 4.12

    @objc var wTabOff:          Int32               /* offset to family glyph-width table from beginning of font family
                                                       resource to beginning of table, in bytes */
    @objc var kernOff:          Int32               /* offset to kerning table from beginning of font family resource to
                                                       beginning of table, in bytes */
    @objc var styleOff:         Int32               /* offset to style mapping table from beginning of font family
                                                       resource to beginning of table, in bytes */

                                                    // style property info; extra widths for different styles
    @objc var ewSPlain:         Fixed4Dot12         // should be 0
    @objc var ewSBold:          Fixed4Dot12
    @objc var ewSItalic:        Fixed4Dot12
    @objc var ewSUnderline:     Fixed4Dot12
    @objc var ewSOutline:       Fixed4Dot12
    @objc var ewSShadow:        Fixed4Dot12
    @objc var ewSCondensed:     Fixed4Dot12
    @objc var ewSExtended:      Fixed4Dot12
    @objc var ewSUnused:        Fixed4Dot12         // unused; should be 0

    @objc var intl0:            Int16               // for international use
    @objc var intl1:            Int16               // for international use

    var ffVersion:              FontFamilyVersion   // version number

    @objc var objcFFFlags:      FontFamilyFlags.RawValue { didSet { ffFlags = FontFamilyFlags(rawValue: objcFFFlags) } }
    @objc var objcFFVersion:    FontFamilyVersion.RawValue {
        didSet { ffVersion = FontFamilyVersion(rawValue: objcFFVersion) ?? .version1 }
    }

    @objc var fontAssociationTable:     FontAssociationTable

    @objc var countOfFontAssociationTableEntries: Int {
        return fontAssociationTable.entries.count
    }

    unowned var resource:               Resource
    private(set) var reader:            BinaryDataReader
    @objc var remainingTableData:       Data

    @objc var offsetTable:              OffsetTable?

    @objc lazy var boundingBoxTable:    BoundingBoxTable? = {
        do {
            try calculateOffsetsIfNeeded()
            // can only have a Bounding Box table if we have an offset table to specify its offset
            if let offsetTable = offsetTable {
                // might have a bounding box table
                let offsetTableOffset = Self.FontFamilyRecord.length + fontAssociationTable.length
                try reader.pushPosition(offsetTableOffset + Int(offsetTable.entries[0].offsetOfTable))
                boundingBoxTable = try BoundingBoxTable(reader)
                reader.popPosition()
            }
            return boundingBoxTable
        } catch {
             NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
        return nil
    }()

    @objc lazy var widthTable:          WidthTable? = {
        if wTabOff == 0 { return nil }
        do {
            try calculateOffsetsIfNeeded()
            try reader.pushPosition(Int(wTabOff))
            widthTable = try WidthTable(reader, fond:self)
            reader.popPosition()
            return widthTable
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
        return nil
    }()

    @objc lazy var styleMappingTable:   StyleMappingTable? = {
        if styleOff == 0 { return nil }
        do {
            try calculateOffsetsIfNeeded()
            if let styleMappingRange = offsetTypesToRanges[.styleTable] {
                try reader.pushPosition(Int(styleOff))
                styleMappingTable = try StyleMappingTable(reader, range:styleMappingRange)
                reader.popPosition()
            } else {
                NSLog("\(type(of: self)).\(#function)() *** ERROR: could not determine styleMappingRange!")
            }
            return styleMappingTable
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
        return nil
    }()

    @objc lazy var kernTable:         KernTable? = {
        if kernOff == 0 { return nil }
        do {
            try calculateOffsetsIfNeeded()
            if let kernRange = offsetTypesToRanges[.kernTable] {
                try reader.pushPosition(Int(kernOff))
                kernTable = try KernTable(reader, fond:self)
                reader.popPosition()
            } else {
                NSLog("\(type(of: self)).\(#function)() *** ERROR: could not determine kernTableRange!")
            }
            return kernTable
        } catch {
             NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
        return nil
    }()

    // used to help inform encoding choice (e.g. Symbol and Dingbat fonts have special encodings)
    lazy var basePostScriptName: String? = {
        if styleOff == 0 { return nil }
        guard let entry = fontAssociationTable.entries.first else { return nil }
        if let postScriptName = self.styleMappingTable?.postScriptNameForFont(with: entry.fontStyle) {
            return postScriptName
        }
        return nil
    }()

    lazy var encoding:              MacEncoding = {
        // FIXME: improve non-MacRoman encodings
        let scriptID = MacEncoding.macScriptID(from: ResID(resource.id))
        NSLog("\(type(of: self)).\(#function)() resID: \(resource.id), scriptID: \(scriptID)")
        var encoding = MacEncoding.macEncoding(for: scriptID, postScriptFontName: self.basePostScriptName)
        if let customGlyphs = self.styleMappingTable?.glyphNameEncodingSubtable {
            encoding.add(custom: GlyphNameEntry.glyphNameEntries(with: customGlyphs.charCodesToGlyphNames))
        }
        return encoding
    }()

    enum TableOffsetType {
        case offsetTable
        case bboxTable
        case widthTable
        case styleTable
        case kernTable
    }

    // FIXME: switch to Swift Ranges
    private var offsetTypesToRanges:    [TableOffsetType: NSRange] = [:]
    private var offsetsCalculated:      Bool = false
    private var needsRepair:            Bool = false   // If this FOND resource's resourceID doesn't match the famID, we need to update the famID
    
    convenience init(_ data: Data, resource: Resource) throws {
        let reader = BinaryDataReader(data)
        try self.init(reader, resource: resource)
    }

    init(_ binReader: BinaryDataReader, resource: Resource) throws {
        // FIXME: deal with FOND w/ no name error
        
        /// hold onto `reader` for future parsing for lazy data structures
        self.reader = binReader
        self.resource = resource

        ffFlags         = try reader.read()
        objcFFFlags     = ffFlags.rawValue
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
        objcFFVersion   = ffVersion.rawValue

        // FIXME: make sure famID == this FOND's resource ID, otherwise repair it
        if self.resource.id != famID {
            needsRepair = true
            famID = ResID(resource.id)
            /* FIXME: we need some way to communicate this up the chain with
             some sort of UI alerting user that resource was repaired and
             needs to be saved etc. */
        }
        // FIXME: add validation/error-checking here

        fontAssociationTable = try FontAssociationTable(reader)

        reader.pushSavedPosition()
        remainingTableData = try reader.readData(length: reader.bytesRemaining)
        reader.popPosition()
        super.init()
    }

    func unitsPerEm(for fontStyle: MacFontStyle) -> UnitsPerEm {
        /* Here we'll assume that if there's a mix of entries for both TrueType
         (fontPointSize of 0) and Bitmap fonts, that the bitmap fonts are merely for
         screen display and don't reference possible PostScript outline fonts.

         Currently, this value for UnitsPerEm is really just a best guess.

         For PS fonts, if we wanted to get a more accurate measurement, we'd parse the
         Mac PostScript Type 1 outline font (file type 'LWFN' w/ 'POST' resources) which holds the
         PFA/PFB font. Inside there is the actual abfTopDict->abfSupplement->UnitsPerEm value,
         though parsing that is a bit beyond the scope of this editor.

         For TT fonts, if we wanted to get a more accurate measurement, we'd look
         at the actual unitsPerEm value in the 'sfnt''s 'head' table, but that's kind of
         outside the scope of this editor. Moreover, an 'sfnt' would likely already have
         a 'kern' or 'GPOS' table, the kern pairs of which would take precedence over
         kerns defined here in the 'FOND'. (The data in an 'sfnt' entry is exactly what a
         Windows .ttf contains: see my answer here https://stackoverflow.com/a/7418915/277952) */
        for entry in fontAssociationTable.entries {
            if entry.fontStyle == fontStyle && entry.fontPointSize == 0 {
                return .trueTypeStandard
            }
        }
        // if there's no TT fonts, then assume the bitmaps are for PostScript fonts
        return .postScriptStandard
    }

    func glyphName(for charCode: CharCode) -> String? {
        // or should this be non-optional and return .notdef?
        return self.encoding.glyphName(for: charCode)
    }

    private func calculateOffsetsIfNeeded() throws {
        if offsetsCalculated == true { return }
        var offsetsToOffsetTypes: [Int32: TableOffsetType] = [:]
        if wTabOff > 0 { offsetsToOffsetTypes[wTabOff] = .widthTable }
        if styleOff > 0 { offsetsToOffsetTypes[styleOff] = .styleTable }
        if kernOff > 0 { offsetsToOffsetTypes[kernOff] = .kernTable }
        let currentOffset: Int32 = Int32(Self.FontFamilyRecord.length) + Int32(fontAssociationTable.length)
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

    func add(_ entry: FontAssociationTableEntry) throws {
        try fontAssociationTable.add(entry)
        shiftOffsetsAndRanges(by: entry.length)
    }

    func remove(_ entry: FontAssociationTableEntry) throws {
        try fontAssociationTable.remove(entry)
        shiftOffsetsAndRanges(by: -entry.length)
    }

    func shiftOffsetsAndRanges(by deltaLength: Int) {
        do {
            try calculateOffsetsIfNeeded()
            // NOTE: the table offsets could be empty (== 0), so check before modifying their values
            if wTabOff > 0 {
                wTabOff += Int32(deltaLength)
                if var range = offsetTypesToRanges[.widthTable] {
                    range.length += deltaLength
                    offsetTypesToRanges[.widthTable] = range
                }
            }
            if kernOff > 0 {
                kernOff += Int32(deltaLength)
                if var range = offsetTypesToRanges[.kernTable] {
                    range.length += deltaLength
                    offsetTypesToRanges[.kernTable] = range
                }
            }
            if styleOff > 0 {
                styleOff += Int32(deltaLength)
                if var range = offsetTypesToRanges[.styleTable] {
                    range.length += deltaLength
                    offsetTypesToRanges[.styleTable] = range
                }
            }
            /* OffsetTable entries measure the offset relative to the beginning of
             the OffsetTable itself. Since that table is located after the font
             association entries, no adjustments to its values are needed. */
        } catch {
             NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
    }

}

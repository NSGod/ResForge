//
//  StyleMappingTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=487

import Foundation
import RFSupport

// "The style-mapping table provides a flexible way to assign font classes and
// to specify character-set encodings. The table contains the font class,
// information about the character-encoding scheme that the font designer used,
// and a mechanism for obtaining the name of the appropriate printer font."

// Style-mapping table : 58 bytes
final class StyleMappingTable: ResourceNode {
    var fontClass:                          FontClass   // UInt16
    var offset:                             Int32       // offset from the start of this table to the glyph-name-encoding subtable component
    var reserved:                           Int32
    var indexes:                            [UInt8]     // [48] Indexes into the Font Name Suffix subtable

    @objc var objcFontClass:                FontClass.RawValue {
        didSet { fontClass = .init(rawValue: objcFontClass) }
    }

    var fontNameSuffixSubtable:             FontNameSuffixSubtable
    @objc var glyphNameEncodingSubtable:    GlyphNameEncodingSubtable?

    class override var length: Int {
        MemoryLayout<FontClass.RawValue>.size + MemoryLayout<Int32>.size * 2 + 48  // 58 bytes
    }

    init(_ reader: BinaryDataReader, range knownRange: NSRange) throws {
        let origOffset = reader.position
        fontClass = try reader.read()
        objcFontClass = fontClass.rawValue
        offset = try reader.read()
        reserved = try reader.read()
        indexes = []
        for _ in 0..<48 {
            let index: UInt8 = try reader.read()
            indexes.append(index)
        }
        var nameSuffixRange = knownRange
        nameSuffixRange.location += Self.length
        nameSuffixRange.length -= Self.length
        var glyphNameTableLength = 0
        if offset != 0 {
            glyphNameTableLength = NSMaxRange(knownRange) - (origOffset + Int(offset))
            nameSuffixRange.length -= glyphNameTableLength
        }
        fontNameSuffixSubtable = try FontNameSuffixSubtable(reader, range: nameSuffixRange)
        if offset != 0 {
            try reader.pushPosition(origOffset + Int(offset))
            glyphNameEncodingSubtable = try GlyphNameEncodingSubtable(reader)
            reader.popPosition()
        }
    }

    func postScriptNameForFont(with style: MacFontStyle) -> String? {
        let entryIndex = indexes[Int(style.compressed().rawValue)]
        return fontNameSuffixSubtable.postScriptNameForFontEntry(at: entryIndex)
    }
}


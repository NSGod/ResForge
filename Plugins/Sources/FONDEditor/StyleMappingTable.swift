//
//  StyleMappingTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=487

import Cocoa
import RFSupport

//        Style-mapping table : 58 bytes

struct StyleMappingTable {
    var fontClass:                  FontClass
    var offset:                     Int32       /* offset from the start of this table to the glyph-name-encoding subtable component */
    var reserved:                   Int32
    var indexes:                    [UInt8]     // [48]

    var fontNameSuffixSubtable:     FontNameSuffixSubtable?
    var glyphNameEncodingSubtable:  GlyphNameEncodingSubtable?

    static let length: Int = MemoryLayout<FontClass>.size + MemoryLayout<Int32>.size * 2 + 48 // 58 bytes
}

extension StyleMappingTable {

    init(_ reader: BinaryDataReader, range knownRange: NSRange) throws {
        var origOffset = reader.position
        fontClass = try reader.read()
        offset = try reader.read()
        reserved = try reader.read()
        for _ in 0..<48 {
            let index: UInt8 = try reader.read()
            indexes.append(index)
        }
        var nameSuffixRange: NSRange = knownRange
        nameSuffixRange.location += Self.length
        nameSuffixRange.length -= Self.length
        var glyphNameTableLength: Int = 0
        if offset != 0 {
            glyphNameTableLength = NSMaxRange(knownRange) - (origOffset + Int(offset))
            nameSuffixRange.length -= glyphNameTableLength
        }
        fontNameSuffixSubtable = try FontNameSuffixSubtable(reader, range: nameSuffixRange)
        if offset != 0 {
            try reader.setPosition(origOffset + Int(offset))
            glyphNameEncodingSubtable = try GlyphNameEncodingSubtable(reader)
        }
    }

    func postScriptNameForFont(with style: MacFontStyle) -> String? {
        let entryIndex = indexes[Int(CompressMacFontStyle(fontStyle: style).rawValue)]
        return fontNameSuffixSubtable?.postScriptNameForFontEntry(at: entryIndex)
    }

}

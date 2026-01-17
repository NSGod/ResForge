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
public final class StyleMappingTable: ResourceNode {
    public var fontClass:                          FontClass   // UInt16
    public var offset:                             Int32       // offset from the start of this table to the glyph-name-encoding subtable component
    public var reserved:                           Int32
    public var indexes:                            [UInt8]     // [48] Indexes into the Font Name Suffix subtable

    @objc var objcFontClass:                FontClass.RawValue {
        didSet { fontClass = .init(rawValue: objcFontClass) }
    }

    var fontNameSuffixSubtable:             FontNameSuffixSubtable
    @objc var glyphNameEncodingSubtable:    GlyphNameEncodingSubtable?

    class public override var length: Int {
        MemoryLayout<FontClass.RawValue>.size + MemoryLayout<Int32>.size * 2 + 48  // 58 bytes
    }

    /* Font class. An integer value that specifies a collection of flags that alert
     the printer driver to what type of PostScript font this font family is. This value
     is represented by the fontClass field of the StyleTable data type.
     The default font class definition is 0, which has settings that indicate
     the printer driver should derive the bold, italic, condense, and extend
     styles from the plain font. Intrinsic fonts are assigned classes (bits 2 through 8)
     that prevent these derivations from occurring. The meanings of the 16 bits of the
     fontClass word are as follows:

     Bit    Meaning
     0        This bit is set to 1 if the font name needs coordinating.
     1        This bit is set to 1 if the Macintosh vector reencoding scheme is required.
              Some glyphs in the Apple character set, such as the Apple glyph, do not occur
              in the standard Adobe character set. This glyph must be mapped in from a font
              that has it, such as the Symbol font, to a font that does not, like Helvetica.
     2        This bit is set to 1 if the font family creates the outline style by changing PaintType, a PostScript variable, to 2.
     3        This bit is set to 1 if the font family disallows simulating the outline style by smearing the glyph and whiting out the middle.
     4        This bit is set to 1 if the font family does not allow simulation of the bold style by smearing the glyphs.
     5        This bit is set to 1 if the font family simulates the bold style by increasing point size.
     6        This bit is set to 1 if the font family disallows simulating the italic style.
     7        This bit is set to 1 if the font family disallows automatic simulation of the condense style.
     8        This bit is set to 1 if the font family disallows automatic simulation of the extend style.
     9        This bit is set to 1 if the font family requires reencoding other than Macintosh vector encoding, in which case the glyph-encoding table is present.
     10       This bit is set to 1 if the font family should have no additional intercharacter spacing other than the space character.
     11–15    Reserved. Should be set to 0.
     */

    public struct FontClass: OptionSet, Hashable {
        public let rawValue: UInt16

        public static let nameNeedsCoordinating         = Self(rawValue: 1 << 0)
        public static let reqMacVectorReEncoding        = Self(rawValue: 1 << 1)
        public static let simOutByPaintType             = Self(rawValue: 1 << 2)
        public static let noSimOutBySmearing            = Self(rawValue: 1 << 3)
        public static let noSimBoldBySmearing           = Self(rawValue: 1 << 4)
        public static let simBoldBySize                 = Self(rawValue: 1 << 5)
        public static let noSimItalic                   = Self(rawValue: 1 << 6)
        public static let noSimCondensed                = Self(rawValue: 1 << 7)
        public static let noSimExtended                 = Self(rawValue: 1 << 8)
        public static let reqOtherVectorReEncoding      = Self(rawValue: 1 << 9)
        public static let noAddSpacing                  = Self(rawValue: 1 << 10)

        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }

        public var classDescription: String {
            switch self {
                case .nameNeedsCoordinating:                   return "nameNeedsCoordinating"
                case .reqMacVectorReEncoding:                  return "reqMacVectorReEncoding"
                case .simOutByPaintType:                       return "simOutByPaintType"
                case .noSimOutBySmearing:                      return "noSimOutBySmearing"
                case .noSimBoldBySmearing:                     return "noSimBoldBySmearing"
                case .simBoldBySize:                           return "simBoldBySize"
                case .noSimItalic:                             return "noSimItalic"
                case .noSimCondensed:                          return "noSimCondensed"
                case .noSimExtended:                           return "noSimExtended"
                case .reqOtherVectorReEncoding:                return "reqOtherVectorReEncoding"
                case .noAddSpacing:                            return "noAddSpacing"
                default:
                    return "unknown (rawValue: \(rawValue))"
            }
        }

        public var description: String {
            if self.rawValue == 0 { return "none" }
            var description = ""
            var i = Self.nameNeedsCoordinating.rawValue
            while i <= Self.noAddSpacing.rawValue {
                let fClass = Self(rawValue: i)
                if self.contains(fClass) {
                    description = description.isEmpty ? fClass.classDescription : "\(description), \(fClass.classDescription)"
                }
                i += 1
            }
            return description
        }

        public var debugDescription: String {
            return description
        }
    }

    // MARK: - init
    public init(_ reader: BinaryDataReader, range knownRange: NSRange) throws {
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

    public func postScriptNameForFont(with style: MacFontStyle) -> String? {
        let entryIndex = indexes[Int(style.compressed().rawValue)]
        return fontNameSuffixSubtable.postScriptNameForFontEntry(at: entryIndex)
    }
}


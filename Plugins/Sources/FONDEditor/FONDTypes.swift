//
//  FONDTypes.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//

import Cocoa
import RFSupport

typealias ResID = Int16

typealias CharCode      = UInt8
typealias UVBMP         = UInt16
typealias EncodingID    = UInt16
typealias LanguageID    = UInt16

typealias Fixed4Dot12 = Int16
fileprivate let fixed4: UInt16 = 1 << 12

func Fixed4Dot12ToDouble(_ x: Fixed4Dot12) -> Double {
    Double(x) * 1.0/Double(fixed4)
}

func DoubleToFixed4Dot12(_ x: Double) -> Fixed4Dot12 {
    Fixed4Dot12(x * Double(fixed4) + (x < 0 ? -0.5 : 0.5))
}

/* Font family flags. An integer value, the bits of which specify general characteristics
 of the font family. This value is represented by the ffFlags field in the FamRec data type.
 The bits in the ffFlags field have the following meanings:

 Bit    Meaning
 0        This bit is reserved by Apple and should be cleared to 0.
 1        This bit is set to 1 if the resource contains a glyph-width table.
 2–11    These bits are reserved by Apple and should be cleared to 0.
 12        This bit is set to 1 if the font family ignores the value of the FractEnable
            global variable when deciding whether to use fixed-point values for stylistic variations;
            the value of bit 13 is then the deciding factor. The value of the FractEnable global
            variable is set by the SetFractEnable procedure.
 13        This bit is set to 1 if the font family should use integer extra width for stylistic variations.
            If not set, the font family should compute the fixed-point extra width from the family
            style-mapping table, but only if the FractEnable global variable has a value of TRUE.
 14        This bit is set to 1 if the family fractional-width table is not used, and is cleared to 0 if the table is used.
 15        This bit is set to 1 if the font family describes fixed-width fonts, and is cleared to 0 if the font describes proportional fonts.
 */

struct FontFamilyFlags: OptionSet, Hashable {
    let rawValue: UInt16

    static let hasGlyphWidthTable       = Self(rawValue: 1 << 1)
    static let ignoreFractEnable        = Self(rawValue: 1 << 12)
    static let useIntegerWidths         = Self(rawValue: 1 << 13)
    static let dontUseFractWidthTable   = Self(rawValue: 1 << 14)
    static let isFixedWidth             = Self(rawValue: 1 << 15)

    init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

/* Version. An integer value that specifies the version number of the font family resource, which
    indicates whether certain tables are available. This value is represented by the ffVersion field
    in the FamRec data type. Because this field has been used inconsistently in the system software,
    it is better to analyze the data in the resource itself instead of relying on the version number.
    The possible values are as follows:
    Value    Meaning
    $0000    Created by the Macintosh system software. The font family resource will not have the glyph-width tables and the fields will contain 0.
    $0001    Original format as designed by the font developer. This font family record probably has the width tables and most of the fields are filled.
    $0002    This record may contain the offset and bounding-box tables.
    $0003    This record definitely contains the offset and bounding-box tables.
 */
enum FontFamilyVersion : UInt16 {
    case version0    = 0,
         version1,
         version2,
         version3
}


struct MacFontStyle: OptionSet, Hashable, Comparable {
    let rawValue: UInt16

//    static let none             = Self(rawValue: 0)
    static let bold             = Self(rawValue: 1 << 0)
    static let italic           = Self(rawValue: 1 << 1)
    static let underline        = Self(rawValue: 1 << 2)
    static let outline          = Self(rawValue: 1 << 3)
    static let shadow           = Self(rawValue: 1 << 4)
    static let condensed        = Self(rawValue: 1 << 5)
    static let extended         = Self(rawValue: 1 << 6)

    init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    static func == (lhs: MacFontStyle, rhs: MacFontStyle) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    static func < (lhs: MacFontStyle, rhs: MacFontStyle) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/// I believe this is since `underline` wouldn't affect any calculated PostScript name?
func CompressMacFontStyle(fontStyle: MacFontStyle) -> MacFontStyle {
    var rawValue: UInt16 = 0
    if fontStyle.contains(.bold) { rawValue += 1 }
    if fontStyle.contains(.italic) { rawValue += 2 }
    if fontStyle.contains(.outline) { rawValue += 4 }
    if fontStyle.contains(.shadow) { rawValue += 8 }
    if fontStyle.contains(.condensed) {
        rawValue += 16
    } else if fontStyle.contains(.extended) {
        rawValue += 32
    }
    return MacFontStyle(rawValue: rawValue)
}


/********  Font Family tables component *********/

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

struct FontClass: OptionSet, Hashable {
    let rawValue: UInt16

    static let nameNeedsCoordinating         = Self(rawValue: 1)
    static let reqMacVectorReEncoding        = Self(rawValue: 2)
    static let simOutByPaintType             = Self(rawValue: 4)
    static let noSimOutBySmearing            = Self(rawValue: 8)
    static let noSimBoldBySmearing           = Self(rawValue: 16)
    static let simBoldBySize                 = Self(rawValue: 32)
    static let noSimItalic                   = Self(rawValue: 64)
    static let noSimCondensed                = Self(rawValue: 128)
    static let noSimExtended                 = Self(rawValue: 256)
    static let reqOtherVectorReEncoding      = Self(rawValue: 512)
    static let noAddSpacing                  = Self(rawValue: 1024)

    init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}


enum UnitsPerEm : Int {
    case postScriptStandard      = 1000
    case trueTypeStandard        = 2048
}

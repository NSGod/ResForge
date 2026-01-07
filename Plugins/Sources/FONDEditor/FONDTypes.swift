//
//  FONDTypes.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//

import Foundation
import RFSupport

typealias ResID         = Int16

typealias CharCode      = UInt8
typealias EncodingID    = UInt16
typealias LanguageID    = UInt16
typealias UVBMP         = UInt16

extension UVBMP {
    static let undefined: UVBMP = 0xFFFF
}

typealias Fixed4Dot12   = Int16

fileprivate let fixed4: UInt16 = 1 << 12

func Fixed4Dot12ToDouble(_ x: Fixed4Dot12) -> Double {
    Double(x) * 1.0/Double(fixed4)
}

func DoubleToFixed4Dot12(_ x: Double) -> Fixed4Dot12 {
    Fixed4Dot12(x * Double(fixed4) + (x < 0 ? -0.5 : 0.5))
}

extension BinaryDataReader {
    public func peek<T: FixedWidthInteger>(bigEndian: Bool? = nil) throws -> T {
        let length = T.bitWidth / 8
        try self.advance(length)
        let val = data.withUnsafeBytes {
            $0.loadUnaligned(fromByteOffset: position-length-data.startIndex, as: T.self)
        }
        try setPosition(position - length)
        return bigEndian ?? self.bigEndian ? T(bigEndian: val) : T(littleEndian: val)
    }
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
enum FontFamilyVersion : UInt16, RawRepresentable {
    case version0    = 0,
         version1,
         version2,
         version3
}


struct MacFontStyle: OptionSet, Hashable, Comparable, CustomStringConvertible {
    let rawValue: UInt16

    static let regular          = Self([])
    static let plain            = Self.regular
    static let normal           = Self.regular
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

    var styleDescription: String {
        switch self {
            case .regular, .plain, .normal: return NSLocalizedString("Regular", comment: "")
            case .bold: return NSLocalizedString("Bold", comment: "")
            case .italic: return NSLocalizedString("Italic", comment: "")
            case .underline: return NSLocalizedString("Underline", comment: "")
            case .outline: return NSLocalizedString("Outline", comment: "")
            case .shadow: return NSLocalizedString("Shadow", comment: "")
            case .condensed: return NSLocalizedString("Condensed", comment: "")
            case .extended: return NSLocalizedString("Extended", comment: "")
            default: return NSLocalizedString("Unknown", comment: "")
        }
    }

    var description: String {
        if self == .regular { return styleDescription }
        var description = ""
        var i = Self.bold.rawValue
        while i <= Self.extended.rawValue {
            let style = MacFontStyle(rawValue: i)
            if self.contains(style) {
                description = description.isEmpty ? style.styleDescription : "\(description) \(style.styleDescription)"
            }
            i *= 2
        }
        return description
    }

    /// I believe this is since `underline` wouldn't affect any calculated PostScript name?
    /// This is used when getting the PostScript name of the font
    func compressed() -> MacFontStyle {
        var rawValue: UInt16 = 0
        if self.contains(.bold) { rawValue += 1 }
        if self.contains(.italic) { rawValue += 2 }
        if self.contains(.outline) { rawValue += 4 }
        if self.contains(.shadow) { rawValue += 8 }
        if self.contains(.condensed) {
            rawValue += 16
        } else if self.contains(.extended) {
            rawValue += 32
        }
        return MacFontStyle(rawValue: rawValue)
    }

    static func == (lhs: MacFontStyle, rhs: MacFontStyle) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    static func < (lhs: MacFontStyle, rhs: MacFontStyle) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
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

    static let nameNeedsCoordinating         = Self(rawValue: 1 << 0)
    static let reqMacVectorReEncoding        = Self(rawValue: 1 << 1)
    static let simOutByPaintType             = Self(rawValue: 1 << 2)
    static let noSimOutBySmearing            = Self(rawValue: 1 << 3)
    static let noSimBoldBySmearing           = Self(rawValue: 1 << 4)
    static let simBoldBySize                 = Self(rawValue: 1 << 5)
    static let noSimItalic                   = Self(rawValue: 1 << 6)
    static let noSimCondensed                = Self(rawValue: 1 << 7)
    static let noSimExtended                 = Self(rawValue: 1 << 8)
    static let reqOtherVectorReEncoding      = Self(rawValue: 1 << 9)
    static let noAddSpacing                  = Self(rawValue: 1 << 10)

    init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

enum UnitsPerEm {
    case custom(Int)
    case postScriptStandard,
         trueTypeStandard

    var rawValue: Int {
        switch self {
            case .custom(let v): return v
            case .postScriptStandard: return 1000
            case .trueTypeStandard: return 2048
        }
    }
}


enum MacScriptID: UInt16 {
    case roman                  = 0
    case japanese               = 1
    case traditionalChinese     = 2
//  case chinese                = .traditionalChinese
    case korean                 = 3
    case arabic                 = 4
    case hebrew                 = 5
    case greek                  = 6
    case cyrillic               = 7
    case rightToLeftSymbol      = 8
    case devanagari             = 9
    case gurmukhi               = 10
    case gujarati               = 11
    case oriya                  = 12
    case bengali                = 13
    case tamil                  = 14
    case telugu                 = 15
    case kannada                = 16
    case malayalam              = 17
    case sinhalese              = 18
    case burmese                = 19
    case khmer                  = 20
    case thai                   = 21
    case laotian                = 22
    case georgian               = 23
    case armenian               = 24
    case simplifiedChinese      = 25
    case tibetan                = 26
    case mongolian              = 27
    case geez                   = 28
//  case ethiopic               = .geez
//  case amharic                = .geez
    case ceRoman                = 29
//  case slavic                 = .ceRoman
    case vietnamese             = 30
    case extendedArabic         = 31
//  case sindhi                 = .extendedArabic
    case uninterpreted          = 32
    case none                   = 0xFFFF
}

extension MacScriptID: CustomStringConvertible {
    var description: String {
        switch self {
            case .roman:                    return "Roman"
            case .japanese:                 return "Japanese"
            case .traditionalChinese:       return "Chinese (Traditional)"
            case .korean:                   return "Korean"
            case .arabic:                   return "Arabic"
            case .hebrew:                   return "Hebrew"
            case .greek:                    return "Greek"
            case .cyrillic:                 return "Cyrillic"
            case .rightToLeftSymbol:        return "Right-to-Left Symbols"
            case .devanagari:               return "Devanagari"
            case .gurmukhi:                 return "Gurmukhi"
            case .gujarati:                 return "Gujarati"
            case .oriya:                    return "Oriya"
            case .bengali:                  return "Bengali"
            case .tamil:                    return "Tamil"
            case .telugu:                   return "Telugu"
            case .kannada:                  return "Kannada"
            case .malayalam:                return "Malayalam"
            case .sinhalese:                return "Sinhalese"
            case .burmese:                  return "Burmese"
            case .khmer:                    return "Khmer"
            case .thai:                     return "Thai"
            case .laotian:                  return "Laotian"
            case .georgian:                 return "Georgian"
            case .armenian:                 return "Armenian"
            case .simplifiedChinese:        return "Chinese (Simplified)"
            case .tibetan:                  return "Tibetan"
            case .mongolian:                return "Mongolian"
            case .geez:                     return "Geez/Ethiopic"
            case .ceRoman:                  return "Central European Roman"
            case .vietnamese:               return "Vietnamese"
            case .extendedArabic:           return "Extended Arabic"
            case .uninterpreted:            return "Uninterpreted Symbols"
            case .none:                     return "None"
        }
    }
}


// Language codes are zero based everywhere but within a 'cmap' table
enum MacLanguageID: UInt16 {
    case english        = 0
    case french         = 1
    case german         = 2
    case italian        = 3
    case dutch          = 4
    case swedish        = 5
    case spanish        = 6
    case danish         = 7
    case portuguese     = 8
    case norwegian      = 9
    case hebrew         = 10
    case japanese       = 11
    case arabic         = 12
    case finnish        = 13
    case greek          = 14
    case icelandic      = 15
    case maltese        = 16
    case turkish        = 17
    case croatian       = 18
    case tradChinese    = 19
    case urdu           = 20
    case hindi          = 21
    case thai           = 22
    case korean         = 23
    case lithuanian     = 24
    case polish         = 25
    case hungarian      = 26
    case estonian       = 27
    case lettish        = 28
//  case latvian        = .lettish
    case saamisk        = 29
//  case lappish        = .saamisk
    case faeroese       = 30
    case farsi          = 31
//  case persian        = .farsi
    case russian        = 32
    case simpChinese    = 33
    case flemish        = 34
    case irish          = 35
    case albanian       = 36
    case romanian       = 37
    case czech          = 38
    case slovak         = 39
    case slovenian      = 40
    case yiddish        = 41
    case serbian        = 42
    case macedonian     = 43
    case bulgarian      = 44
    case ukrainian      = 45
    case byelorussian   = 46
    case uzbek          = 47
    case kazakh         = 48
    case azerbaijani    = 49
    case azerbaijanAr   = 50
    case armenian       = 51
    case georgian       = 52
    case moldavian      = 53
    case kirghiz        = 54
    case tajiki         = 55
    case turkmen        = 56
    case mongolian      = 57
    case mongolianCyr   = 58
    case pashto         = 59
    case kurdish        = 60
    case kashmiri       = 61
    case sindhi         = 62
    case tibetan        = 63
    case nepali         = 64
    case sanskrit       = 65
    case marathi        = 66
    case bengali        = 67
    case assamese       = 68
    case gujarati       = 69
    case punjabi        = 70
    case oriya          = 71
    case malayalam      = 72
    case kannada        = 73
    case tamil          = 74
    case telugu         = 75
    case sinhalese      = 76
    case burmese        = 77
    case khmer          = 78
    case lao            = 79
    case vietnamese     = 80
    case indonesian     = 81
    case tagalog        = 82
    case malayRoman     = 83
    case malayArabic    = 84
    case amharic        = 85
    case tigrinya       = 86
    case galla          = 87
//  case oromo          = .galla
    case somali         = 88
    case swahili        = 89
    case ruanda         = 90
    case rundi          = 91
    case chewa          = 92
    case malagasy       = 93
    case esperanto      = 94
    case welsh          = 128
    case basque         = 129
    case catalan        = 130
    case latin          = 131
    case quechua        = 132
    case guarani        = 133
    case aymara         = 134
    case tatar          = 135
    case uighur         = 136
    case dzongkha       = 137
    case javaneseRom    = 138
    case sundaneseRom   = 139
    case none           = 0xFFFF
};

extension MacLanguageID: CustomStringConvertible {
    var description: String {
        switch self {
            case .english:          return "English"
            case .french:           return "French"
            case .german:           return "German"
            case .italian:          return "Italian"
            case .dutch:            return "Dutch"
            case .swedish:          return "Swedish"
            case .spanish:          return "Spanish"
            case .danish:           return "Danish"
            case .portuguese:       return "Portuguese"
            case .norwegian:        return "Norwegian"
            case .hebrew:           return "Hebrew"
            case .japanese:         return "Japanese"
            case .arabic:           return "Arabic"
            case .finnish:          return "Finnish"
            case .greek:            return "Greek"
            case .icelandic:        return "Icelandic"
            case .maltese:          return "Maltese"
            case .turkish:          return "Turkish"
            case .croatian:         return "Croatian"
            case .tradChinese:      return "Chinese (Traditional)"
            case .urdu:             return "Urdu"
            case .hindi:            return "Hindi"
            case .thai:             return "Thai"
            case .korean:           return "Korean"
            case .lithuanian:       return "Lithuanian"
            case .polish:           return "Polish"
            case .hungarian:        return "Hungarian"
            case .estonian:         return "Estonian"
            case .lettish:          return "Lettish"
//          case .latvian           return "Latvian"
            case .saamisk:          return "Saamisk"
//          case .lappish           return "Lappish"
            case .faeroese:         return "Faeroese"
            case .farsi:            return "Farsi"
//          case .persian           return "Persian"
            case .russian:          return "Russian"
            case .simpChinese:      return "Chinese (Simplified)"
            case .flemish:          return "Flemish"
            case .irish:            return "Irish"
            case .albanian:         return "Albanian"
            case .romanian:         return "Romanian"
            case .czech:            return "Czech"
            case .slovak:           return "Slovak"
            case .slovenian:        return "Slovenian"
            case .yiddish:          return "Yiddish"
            case .serbian:          return "Serbian"
            case .macedonian:       return "Macedonian"
            case .bulgarian:        return "Bulgarian"
            case .ukrainian:        return "Ukrainian"
            case .byelorussian:     return "Byelorussian"
            case .uzbek:            return "Uzbek"
            case .kazakh:           return "Kazakh"
            case .azerbaijani:      return "Azerbaijani"
            case .azerbaijanAr:     return "Azerbaijan (Armenian)"
            case .armenian:         return "Armenian"
            case .georgian:         return "Georgian"
            case .moldavian:        return "Moldavian"
            case .kirghiz:          return "Kirghiz"
            case .tajiki:           return "Tajiki"
            case .turkmen:          return "Turkmen"
            case .mongolian:        return "Mongolian"
            case .mongolianCyr:     return "Mongolian (Cyrillic)"
            case .pashto:           return "Pashto"
            case .kurdish:          return "Kurdish"
            case .kashmiri:         return "Kashmiri"
            case .sindhi:           return "Sindhi"
            case .tibetan:          return "Tibetan"
            case .nepali:           return "Nepali"
            case .sanskrit:         return "Sanskrit"
            case .marathi:          return "Marathi"
            case .bengali:          return "Bengali"
            case .assamese:         return "Assamese"
            case .gujarati:         return "Gujarati"
            case .punjabi:          return "Punjabi"
            case .oriya:            return "Oriya"
            case .malayalam:        return "Malayalam"
            case .kannada:          return "Kannada"
            case .tamil:            return "Tamil"
            case .telugu:           return "Telugu"
            case .sinhalese:        return "Sinhalese"
            case .burmese:          return "Burmese"
            case .khmer:            return "Khmer"
            case .lao:              return "Lao"
            case .vietnamese:       return "Vietnamese"
            case .indonesian:       return "Indonesian"
            case .tagalog:          return "Tagalog"
            case .malayRoman:       return "MalayRoman"
            case .malayArabic:      return "MalayArabic"
            case .amharic:          return "Amharic"
            case .tigrinya:         return "Tigrinya"
            case .galla:            return "Galla"
//          case .oromo             return "Oromo"
            case .somali:           return "Somali"
            case .swahili:          return "Swahili"
            case .ruanda:           return "Ruanda"
            case .rundi:            return "Rundi"
            case .chewa:            return "Chewa"
            case .malagasy:         return "Malagasy"
            case .esperanto:        return "Esperanto"
            case .welsh:            return "Welsh"
            case .basque:           return "Basque"
            case .catalan:          return "Catalan"
            case .latin:            return "Latin"
            case .quechua:          return "Quechua"
            case .guarani:          return "Guarani"
            case .aymara:           return "Aymara"
            case .tatar:            return "Tatar"
            case .uighur:           return "Uighur"
            case .dzongkha:         return "Dzongkha"
            case .javaneseRom:      return "Javanese"
            case .sundaneseRom:     return "Sundanese"
            case .none:             return "--"
        }
    }
}

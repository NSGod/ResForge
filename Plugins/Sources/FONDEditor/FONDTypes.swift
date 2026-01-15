//
//  FONDTypes.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//

import Foundation
import RFSupport

public typealias ResID         = Int16

public typealias CharCode      = UInt8
public typealias CharCode16    = UInt16

public extension CharCode {
    static let space: CharCode = 0x20
}

public extension CharCode16 {
    static let space: CharCode16 = 0x20
}

//typealias EncodingID    = UInt16
//typealias LanguageID    = UInt16

public typealias UVBMP         = UInt16

public extension UVBMP {
    static let undefined: UVBMP = 0xFFFF
}

public typealias Fixed4Dot12   = Int16

fileprivate let fixed4: UInt16 = 1 << 12

public func Fixed4Dot12ToDouble(_ x: Fixed4Dot12) -> Double {
    Double(x) * 1.0/Double(fixed4)
}

public func DoubleToFixed4Dot12(_ x: Double) -> Fixed4Dot12 {
    Fixed4Dot12(x * Double(fixed4) + (x < 0 ? -0.5 : 0.5))
}

public extension BinaryDataReader {
    func peek<T: FixedWidthInteger>(bigEndian: Bool? = nil) throws -> T {
        let length = T.bitWidth / 8
        try self.advance(length)
        let val = data.withUnsafeBytes {
            $0.loadUnaligned(fromByteOffset: position-length-data.startIndex, as: T.self)
        }
        try self.advance(-length)
        return bigEndian ?? self.bigEndian ? T(bigEndian: val) : T(littleEndian: val)
    }
}

public struct MacFontStyle: OptionSet, Hashable, Comparable, CustomStringConvertible {
    public let rawValue: UInt16

    static let regular          = Self([])
    static let plain            = Self.regular
    static let normal           = Self.regular
    static let bold             = Self(rawValue: 1 << 0)    // 1
    static let italic           = Self(rawValue: 1 << 1)    // 2
    static let underline        = Self(rawValue: 1 << 2)    // 4
    static let outline          = Self(rawValue: 1 << 3)    // 8
    static let shadow           = Self(rawValue: 1 << 4)    // 16
    static let condensed        = Self(rawValue: 1 << 5)    // 32
    static let extended         = Self(rawValue: 1 << 6)    // 64

    public init(rawValue: UInt16) {
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

    public var description: String {
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

    /// Assuming Condensed and Extended are mutually-exclusive, that makes the maximum value
    /// of all possible combination of styles to be 32 + 8 + 4 + 2 + 1 = 47. Add 1 for no
    /// style and you have 48. So, when trying to look up the PostScript name in the
    /// StyleMappingTable, we compress the style value first before finding the index in indexes UInt8[48].
    /// This is used when getting the PostScript name of the font
    public func compressed() -> MacFontStyle {
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

    public static func == (lhs: MacFontStyle, rhs: MacFontStyle) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public static func < (lhs: MacFontStyle, rhs: MacFontStyle) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public enum UnitsPerEm {
    case custom(Int)
    case postScriptStandard,
         trueTypeStandard

    public init(rawValue: Int) {
        if rawValue == 1000 {
            self = .postScriptStandard
        } else if rawValue == 2048 {
            self = .trueTypeStandard
        } else {
            self = .custom(rawValue)
        }
    }

    public var rawValue: Int {
        switch self {
            case .custom(let v): return v
            case .postScriptStandard: return 1000
            case .trueTypeStandard: return 2048
        }
    }
}

public enum MacScriptID: UInt16 {
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
    public var description: String {
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
public enum MacLanguageID: UInt16 {
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
    public var description: String {
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

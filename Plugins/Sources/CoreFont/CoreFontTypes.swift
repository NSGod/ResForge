//
//  CoreFontTypes.swift
//  CoreFont
//
//  Created by Mark Douma on 1/18/2026.
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

public struct MacFontStyle: OptionSet, Hashable, Comparable, CustomStringConvertible {
    public let rawValue: UInt16

    public static let regular          = Self([])
    public static let plain            = Self.regular
    public static let normal           = Self.regular
    public static let bold             = Self(rawValue: 1 << 0)    // 1
    public static let italic           = Self(rawValue: 1 << 1)    // 2
    public static let underline        = Self(rawValue: 1 << 2)    // 4
    public static let outline          = Self(rawValue: 1 << 3)    // 8
    public static let shadow           = Self(rawValue: 1 << 4)    // 16
    public static let condensed        = Self(rawValue: 1 << 5)    // 32
    public static let extended         = Self(rawValue: 1 << 6)    // 64

    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    public var styleDescription: String {
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
    case custom(UInt16)
    case postScriptStandard,
         trueTypeStandard

    public init(rawValue: UInt16) {
        if rawValue == 1000 {
            self = .postScriptStandard
        } else if rawValue == 2048 {
            self = .trueTypeStandard
        } else {
            self = .custom(rawValue)
        }
    }

    public var rawValue: UInt16 {
        switch self {
            case .custom(let v): return v
            case .postScriptStandard: return 1000
            case .trueTypeStandard: return 2048
        }
    }
}

public protocol FontMetrics {
    var unitsPerEm:         UnitsPerEm  { get }
    var ascender:           CGFloat     { get }
    var descender:          CGFloat     { get }
    var leading:            CGFloat     { get }

    var underlinePosition:  CGFloat     { get }
    var underlineThickness: CGFloat     { get }
    var italicAngle:        CGFloat     { get }
    var capHeight:          CGFloat     { get }
    var xHeight:            CGFloat     { get }
    var isFixedPitch:       Bool        { get }
}

// See CoreServices/CarbonCore/Script.h
@objc public enum MacScriptID: UInt16, Comparable {
    case roman                  = 0
    case japanese               = 1
    case tradChinese            = 2
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
    case lao                    = 22
    case georgian               = 23
    case armenian               = 24
    case simpChinese            = 25
    case tibetan                = 26
    case mongolian              = 27
    case ethiopic               = 28
    case ceRoman                = 29
    case vietnamese             = 30
    case extendedArabic         = 31
    case uninterpreted          = 32
    case none                   = 0xFFFF // mine

    public static func < (lhs: MacScriptID, rhs: MacScriptID) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    public static func == (lhs: MacScriptID, rhs: MacScriptID) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension MacScriptID: CustomStringConvertible {
    public var description: String {
        switch self {
            case .roman:                    return NSLocalizedString("Roman", comment: "")
            case .japanese:                 return NSLocalizedString("Japanese", comment: "")
            case .tradChinese:              return NSLocalizedString("Chinese (Traditional)", comment: "")
            case .korean:                   return NSLocalizedString("Korean", comment: "")
            case .arabic:                   return NSLocalizedString("Arabic", comment: "")
            case .hebrew:                   return NSLocalizedString("Hebrew", comment: "")
            case .greek:                    return NSLocalizedString("Greek", comment: "")
            case .cyrillic:                 return NSLocalizedString("Cyrillic", comment: "")
            case .rightToLeftSymbol:        return NSLocalizedString("Right-to-Left Symbols", comment: "")
            case .devanagari:               return NSLocalizedString("Devanagari", comment: "")
            case .gurmukhi:                 return NSLocalizedString("Gurmukhi", comment: "")
            case .gujarati:                 return NSLocalizedString("Gujarati", comment: "")
            case .oriya:                    return NSLocalizedString("Oriya", comment: "")
            case .bengali:                  return NSLocalizedString("Bengali", comment: "")
            case .tamil:                    return NSLocalizedString("Tamil", comment: "")
            case .telugu:                   return NSLocalizedString("Telugu", comment: "")
            case .kannada:                  return NSLocalizedString("Kannada", comment: "")
            case .malayalam:                return NSLocalizedString("Malayalam", comment: "")
            case .sinhalese:                return NSLocalizedString("Sinhalese", comment: "")
            case .burmese:                  return NSLocalizedString("Burmese", comment: "")
            case .khmer:                    return NSLocalizedString("Khmer", comment: "")
            case .thai:                     return NSLocalizedString("Thai", comment: "")
            case .lao:                      return NSLocalizedString("Laotian", comment: "")
            case .georgian:                 return NSLocalizedString("Georgian", comment: "")
            case .armenian:                 return NSLocalizedString("Armenian", comment: "")
            case .simpChinese:              return NSLocalizedString("Chinese (Simplified)", comment: "")
            case .tibetan:                  return NSLocalizedString("Tibetan", comment: "")
            case .mongolian:                return NSLocalizedString("Mongolian", comment: "")
            case .ethiopic:                 return NSLocalizedString("Ethiopic", comment: "")
            case .ceRoman:                  return NSLocalizedString("Central European Roman", comment: "")
            case .vietnamese:               return NSLocalizedString("Vietnamese", comment: "")
            case .extendedArabic:           return NSLocalizedString("Extended Arabic", comment: "")
            case .uninterpreted:            return NSLocalizedString("Uninterpreted Symbols", comment: "")
            case .none:                     return NSLocalizedString("None", comment: "")
        }
    }
}

// See CoreServices/CarbonCore/Script.h
// Language codes are zero based everywhere but within a 'cmap' table
@objc public enum MacLanguageID: UInt16, Comparable {
    case english            = 0     // .roman script
    case french             = 1     // .roman script
    case german             = 2     // .roman script
    case italian            = 3     // .roman script
    case dutch              = 4     // .roman script
    case swedish            = 5     // .roman script
    case spanish            = 6     // .roman script
    case danish             = 7     // .roman script
    case portuguese         = 8     // .roman script
    case norwegian          = 9     // .roman script
    case hebrew             = 10    // .hebrew script
    case japanese           = 11    // .japanese script
    case arabic             = 12    // .arabic script
    case finnish            = 13    // .roman script
    case greek              = 14    // Greek script (monotonic) using .roman script
    case icelandic          = 15    // modified .roman/Icelandic script
    case maltese            = 16    // .roman script
    case turkish            = 17    // modified .roman/Turkish script
    case croatian           = 18    // modified .roman/Croatian script
    case tradChinese        = 19    // Mandarin in .tradChinese script
    case urdu               = 20    // .arabic script
    case hindi              = 21    // .devanagari script
    case thai               = 22    // .thai script
    case korean             = 23    // .korean script
    case lithuanian         = 24    // .ceRoman script
    case polish             = 25    // .ceRoman script
    case hungarian          = 26    // .ceRoman script
    case estonian           = 27    // .ceRoman script
    case latvian            = 28    // .ceRoman script
    case sami               = 29    // .ceRoman script
    case faroese            = 30    // modified .roman/Icelandic script
    case farsi              = 31    // modified .arabic/Farsi script
//  case persian            = .farsi
    case russian            = 32    // .cyrillic script
    case simpChinese        = 33    // .simpChinese script
    case flemish            = 34    // .roman script
    case irishGaelic        = 35    // .roman or modified .roman/Celtic script (without dot above)
    case albanian           = 36    // .roman script
    case romanian           = 37    // modified .roman/Romanian script
    case czech              = 38    // .ceRoman script
    case slovak             = 39    // .ceRoman script
    case slovenian          = 40    // modified .roman/Croatian script
    case yiddish            = 41    // .hebrew script
    case serbian            = 42    // .cyrillic script
    case macedonian         = 43    // .cyrillic script
    case bulgarian          = 44    // .cyrillic script
    case ukrainian          = 45    // modified .cyrillic/Ukranian script
    case byelorussian       = 46    // .cyrillic script
    case uzbek              = 47    // .cyrillic script
    case kazakh             = 48    // .cyrillic script
    case azerbaijani        = 49    // Azerbaijani in .cyrillic script
    case azerbaijanAr       = 50    // Azerbaijani in .arabic script
    case armenian           = 51    // .armenian script
    case georgian           = 52    // .georgian script
    case moldavian          = 53    // .cyrillic script
    case kirghiz            = 54    // .cyrillic script
    case tajiki             = 55    // .cyrillic script
    case turkmen            = 56    // .cyrillic script
    case mongolian          = 57    // Mongolian in .mongolian script
    case mongolianCyr       = 58    // Mongolian in .cyrillic script
    case pashto             = 59    // .arabic script
    case kurdish            = 60    // .arabic script
    case kashmiri           = 61    // .arabic script
    case sindhi             = 62    // .arabic script
    case tibetan            = 63    // .tibetan script
    case nepali             = 64    // .devanagari script
    case sanskrit           = 65    // .devanagari script
    case marathi            = 66    // .devanagari script
    case bengali            = 67    // .bengali script
    case assamese           = 68    // .bengali script
    case gujarati           = 69    // .gujarati script
    case punjabi            = 70    // .gurmukhi script
    case oriya              = 71    // .oriya script
    case malayalam          = 72    // .malayalam script
    case kannada            = 73    // .kannada script
    case tamil              = 74    // .tamil script
    case telugu             = 75    // .telugu script
    case sinhalese          = 76    // .sinhalese script
    case burmese            = 77    // .burmese script
    case khmer              = 78    // .khmer script
    case lao                = 79    // .lao script
    case vietnamese         = 80    // .vietnamese script
    case indonesian         = 81    // .roman script
    case tagalog            = 82    // .roman script
    case malayRoman         = 83    // Malay in .roman script
    case malayArabic        = 84    // Malay in .arabic script
    case amharic            = 85    // .ethiopic script
    case tigrinya           = 86    // .ethiopic script
    case oromo              = 87    // .ethiopic script
    case somali             = 88    // .roman script
    case swahili            = 89    // .roman script
    case ruanda             = 90    // .roman script
    case rundi              = 91    // .roman script
    case nyanja             = 92    // .roman script
    case malagasy           = 93    // .roman script
    case esperanto          = 94    // .roman script
    case welsh              = 128   // modified .roman/Celtic script
    case basque             = 129   // .roman script
    case catalan            = 130   // .roman script
    case latin              = 131   // .roman script
    case quechua            = 132   // .roman script
    case guarani            = 133   // .roman script
    case aymara             = 134   // .roman script
    case tatar              = 135   // .cyrllic script
    case uighur             = 136   // .arabic script
    case dzongkha           = 137   // .tibetan script
    case javaneseRom        = 138   // javanese in .roman script
    case sundaneseRom       = 139   // sudanese in .roman script
    case galician           = 140   // .roman script
    case afrikaans          = 141   // .roman script
    case breton             = 142   // .roman or modified .roman/Celtic script
    case inuktitut          = 143   // Intuit using .ethiopic script
    case scottishGaelic     = 144   // .roman or modified .roman/Celtic script
    case manxGaelic         = 145   // .roman or modified .roman/Celtic script
    case irishGaelicDot     = 146   // modified .roman/Gaelic (with dot above) script
    case tongan             = 147   // .roman script
    case greekAncient       = 148   // Classical Greek, polytonic orthography; script == ?
    case greenlandic        = 149   // .roman script
    case azerbaijanRoman    = 150   // Azerbaijani in .roman script
    case nynorsk            = 151   // Norwegian Nyorsk in .roman script
    case none               = 0xFFFF

    public static func < (lhs: MacLanguageID, rhs: MacLanguageID) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public static func == (lhs: MacLanguageID, rhs: MacLanguageID) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension MacLanguageID: CustomStringConvertible {
    public var description: String {
        switch self {
            case .english:          return NSLocalizedString("English", comment: "")
            case .french:           return NSLocalizedString("French", comment: "")
            case .german:           return NSLocalizedString("German", comment: "")
            case .italian:          return NSLocalizedString("Italian", comment: "")
            case .dutch:            return NSLocalizedString("Dutch", comment: "")
            case .swedish:          return NSLocalizedString("Swedish", comment: "")
            case .spanish:          return NSLocalizedString("Spanish", comment: "")
            case .danish:           return NSLocalizedString("Danish", comment: "")
            case .portuguese:       return NSLocalizedString("Portuguese", comment: "")
            case .norwegian:        return NSLocalizedString("Norwegian", comment: "")
            case .hebrew:           return NSLocalizedString("Hebrew", comment: "")
            case .japanese:         return NSLocalizedString("Japanese", comment: "")
            case .arabic:           return NSLocalizedString("Arabic", comment: "")
            case .finnish:          return NSLocalizedString("Finnish", comment: "")
            case .greek:            return NSLocalizedString("Greek", comment: "")
            case .icelandic:        return NSLocalizedString("Icelandic", comment: "")
            case .maltese:          return NSLocalizedString("Maltese", comment: "")
            case .turkish:          return NSLocalizedString("Turkish", comment: "")
            case .croatian:         return NSLocalizedString("Croatian", comment: "")
            case .tradChinese:      return NSLocalizedString("Chinese (Traditional)", comment: "")
            case .urdu:             return NSLocalizedString("Urdu", comment: "")
            case .hindi:            return NSLocalizedString("Hindi", comment: "")
            case .thai:             return NSLocalizedString("Thai", comment: "")
            case .korean:           return NSLocalizedString("Korean", comment: "")
            case .lithuanian:       return NSLocalizedString("Lithuanian", comment: "")
            case .polish:           return NSLocalizedString("Polish", comment: "")
            case .hungarian:        return NSLocalizedString("Hungarian", comment: "")
            case .estonian:         return NSLocalizedString("Estonian", comment: "")
            case .latvian:          return NSLocalizedString("Latvian", comment: "")
            case .sami:             return NSLocalizedString("Sami", comment: "")
            case .faroese:          return NSLocalizedString("Faroese", comment: "")
            case .farsi:            return NSLocalizedString("Farsi", comment: "")
//          case .persian           return "Persian"
            case .russian:          return NSLocalizedString("Russian", comment: "")
            case .simpChinese:      return NSLocalizedString("Chinese (Simplified)", comment: "")
            case .flemish:          return NSLocalizedString("Flemish", comment: "")
            case .irishGaelic:      return NSLocalizedString("Irish Gaelic", comment: "")
            case .albanian:         return NSLocalizedString("Albanian", comment: "")
            case .romanian:         return NSLocalizedString("Romanian", comment: "")
            case .czech:            return NSLocalizedString("Czech", comment: "")
            case .slovak:           return NSLocalizedString("Slovak", comment: "")
            case .slovenian:        return NSLocalizedString("Slovenian", comment: "")
            case .yiddish:          return NSLocalizedString("Yiddish", comment: "")
            case .serbian:          return NSLocalizedString("Serbian", comment: "")
            case .macedonian:       return NSLocalizedString("Macedonian", comment: "")
            case .bulgarian:        return NSLocalizedString("Bulgarian", comment: "")
            case .ukrainian:        return NSLocalizedString("Ukrainian", comment: "")
            case .byelorussian:     return NSLocalizedString("Byelorussian", comment: "")
            case .uzbek:            return NSLocalizedString("Uzbek", comment: "")
            case .kazakh:           return NSLocalizedString("Kazakh", comment: "")
            case .azerbaijani:      return NSLocalizedString("Azerbaijani", comment: "")
            case .azerbaijanAr:     return NSLocalizedString("Azerbaijan (Armenian)", comment: "")
            case .armenian:         return NSLocalizedString("Armenian", comment: "")
            case .georgian:         return NSLocalizedString("Georgian", comment: "")
            case .moldavian:        return NSLocalizedString("Moldavian", comment: "")
            case .kirghiz:          return NSLocalizedString("Kirghiz", comment: "")
            case .tajiki:           return NSLocalizedString("Tajiki", comment: "")
            case .turkmen:          return NSLocalizedString("Turkmen", comment: "")
            case .mongolian:        return NSLocalizedString("Mongolian", comment: "")
            case .mongolianCyr:     return NSLocalizedString("Mongolian (Cyrillic)", comment: "")
            case .pashto:           return NSLocalizedString("Pashto", comment: "")
            case .kurdish:          return NSLocalizedString("Kurdish", comment: "")
            case .kashmiri:         return NSLocalizedString("Kashmiri", comment: "")
            case .sindhi:           return NSLocalizedString("Sindhi", comment: "")
            case .tibetan:          return NSLocalizedString("Tibetan", comment: "")
            case .nepali:           return NSLocalizedString("Nepali", comment: "")
            case .sanskrit:         return NSLocalizedString("Sanskrit", comment: "")
            case .marathi:          return NSLocalizedString("Marathi", comment: "")
            case .bengali:          return NSLocalizedString("Bengali", comment: "")
            case .assamese:         return NSLocalizedString("Assamese", comment: "")
            case .gujarati:         return NSLocalizedString("Gujarati", comment: "")
            case .punjabi:          return NSLocalizedString("Punjabi", comment: "")
            case .oriya:            return NSLocalizedString("Oriya", comment: "")
            case .malayalam:        return NSLocalizedString("Malayalam", comment: "")
            case .kannada:          return NSLocalizedString("Kannada", comment: "")
            case .tamil:            return NSLocalizedString("Tamil", comment: "")
            case .telugu:           return NSLocalizedString("Telugu", comment: "")
            case .sinhalese:        return NSLocalizedString("Sinhalese", comment: "")
            case .burmese:          return NSLocalizedString("Burmese", comment: "")
            case .khmer:            return NSLocalizedString("Khmer", comment: "")
            case .lao:              return NSLocalizedString("Lao", comment: "")
            case .vietnamese:       return NSLocalizedString("Vietnamese", comment: "")
            case .indonesian:       return NSLocalizedString("Indonesian", comment: "")
            case .tagalog:          return NSLocalizedString("Tagalog", comment: "")
            case .malayRoman:       return NSLocalizedString("Malay (Roman)", comment: "")
            case .malayArabic:      return NSLocalizedString("Malay (Arabic)", comment: "")
            case .amharic:          return NSLocalizedString("Amharic", comment: "")
            case .tigrinya:         return NSLocalizedString("Tigrinya", comment: "")
            case .oromo:            return NSLocalizedString("Oromo", comment: "")
            case .somali:           return NSLocalizedString("Somali", comment: "")
            case .swahili:          return NSLocalizedString("Swahili", comment: "")
            case .ruanda:           return NSLocalizedString("Ruanda", comment: "")
            case .rundi:            return NSLocalizedString("Rundi", comment: "")
            case .nyanja:           return NSLocalizedString("Nyanja", comment: "")
            case .malagasy:         return NSLocalizedString("Malagasy", comment: "")
            case .esperanto:        return NSLocalizedString("Esperanto", comment: "")
            case .welsh:            return NSLocalizedString("Welsh", comment: "")
            case .basque:           return NSLocalizedString("Basque", comment: "")
            case .catalan:          return NSLocalizedString("Catalan", comment: "")
            case .latin:            return NSLocalizedString("Latin", comment: "")
            case .quechua:          return NSLocalizedString("Quechua", comment: "")
            case .guarani:          return NSLocalizedString("Guarani", comment: "")
            case .aymara:           return NSLocalizedString("Aymara", comment: "")
            case .tatar:            return NSLocalizedString("Tatar", comment: "")
            case .uighur:           return NSLocalizedString("Uighur", comment: "")
            case .dzongkha:         return NSLocalizedString("Dzongkha", comment: "")
            case .javaneseRom:      return NSLocalizedString("Javanese (Roman)", comment: "")
            case .sundaneseRom:     return NSLocalizedString("Sundanese (Roman)", comment: "")
            case .galician:         return NSLocalizedString("Galician", comment: "")
            case .afrikaans:		return NSLocalizedString("Afrikaans", comment: "")
            case .breton:			return NSLocalizedString("Breton", comment: "")
            case .inuktitut:		return NSLocalizedString("Inuktitut", comment: "")
            case .scottishGaelic:	return NSLocalizedString("Scottish Gaelic", comment: "")
            case .manxGaelic:		return NSLocalizedString("Manx Gaelic", comment: "")
            case .irishGaelicDot:   return NSLocalizedString("Irish Gaelic (with dot above)", comment: "")
            case .tongan:			return NSLocalizedString("Tongan", comment: "")
            case .greekAncient:		return NSLocalizedString("Greek (polytonic)", comment: "")
            case .greenlandic:		return NSLocalizedString("Greenlandic", comment: "")
            case .azerbaijanRoman:	return NSLocalizedString("Azerbaijani (Roman)", comment: "")
            case .nynorsk:			return NSLocalizedString("Nynorsk", comment: "")
            case .none:             return NSLocalizedString("--", comment: "")
        }
    }
}

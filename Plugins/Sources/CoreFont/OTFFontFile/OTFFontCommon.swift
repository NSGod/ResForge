//
//  OTFFontCommon.swift
//  CoreFont
//
//  Created by Mark Douma on 1/10/2026.
//

import Foundation
import RFSupport

public typealias GlyphID   = UInt16
public typealias Glyph32ID = UInt32

public extension GlyphID {
    static let notDef:      GlyphID = 0x0000       // GID of .notdef glyph
//    static let undefined:   GlyphID = 0xFFFF    // GID of undefined glyph
}

// Fixed: 16-bit signed integer plus 16-bit fraction
public typealias Fixed = Int32

fileprivate let fixedScale: UInt32 = 1 << 16

public func FixedToDouble(_ x: Fixed) -> Double {
    Double(x) * 1.0/Double(fixedScale)
}
public func DoubleToFixed(_ x: Double) -> Fixed {
    Fixed(x * Double(fixedScale) + (x < 0 ? -0.5 : 0.5))
}
public func FixedToFloat(_ x: Fixed) -> Float {
    Float(x) * 1.0/Float(fixedScale)
}

public extension Fixed {
    func makeVersion(_ major: Int32, _ minor: Int32) -> Fixed {
        return Fixed(major << 16 | minor << 12) // "Strange but true, thanks Apple"
    }
}

public typealias Tag       = UInt32

public extension FixedWidthInteger {
    var uint32AlignedCount: Int {
        Int((self + 3) & -4)
    }
}

public struct OTFsfntFormat: RawRepresentable, Equatable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let `true`:  OTFsfntFormat = .init(rawValue: UInt32(fourCharString: "true"))
    public static let OTTO:    OTFsfntFormat = .init(rawValue: UInt32(fourCharString: "OTTO"))
    public static let typ1:    OTFsfntFormat = .init(rawValue: UInt32(fourCharString: "typ1"))
    public static let V1_0:    OTFsfntFormat = .init(rawValue: 0x00010000)
    public static let ttcf:    OTFsfntFormat = .init(rawValue: UInt32(fourCharString: "ttcf"))
    public static let _kbd:    OTFsfntFormat = .init(rawValue: 0xA56B6264) // '•kbd'    .Keyboard
    public static let _lst:    OTFsfntFormat = .init(rawValue: 0xA56C7374) // '•lst'    .LastResort
    public static let vt10:    OTFsfntFormat = .init(rawValue: 0x35ECFAA2) // VT100
    public static let vt1b:    OTFsfntFormat = .init(rawValue: 0x498182F0) // VT100-Bold
}

public struct TableTag: RawRepresentable, Comparable, Hashable, CustomStringConvertible {
    public let rawValue: Tag

    public init(rawValue: Tag) {
        self.rawValue = rawValue
    }

    public static let BASE = Self(rawValue: Tag(fourCharString: "BASE")) // Baseline data table (opt)
    public static let CFF_ = Self(rawValue: Tag(fourCharString: "CFF ")) // Compact Font Format 1.0        OT (req)
    public static let CFF2 = Self(rawValue: Tag(fourCharString: "CFF2")) // Compact Font Format 2.0        OT (req)
    public static let DSIG = Self(rawValue: Tag(fourCharString: "DSIG")) // digital signature (opt)

    public static let TYP1 = Self(rawValue: Tag(fourCharString: "TYP1")) //
    public static let CID_ = Self(rawValue: Tag(fourCharString: "CID ")) //
    public static let gcid = Self(rawValue: Tag(fourCharString: "gcid")) // glyphIDs to CMap CIDs table    TT (opt)

    public static let BLND = Self(rawValue: Tag(fourCharString: "BLND")) //

    public static let EBDT = Self(rawValue: Tag(fourCharString: "EBDT")) // Embedded bitmap data (B&W/grayscale) (bitmap-only TT fonts)
    public static let EBLC = Self(rawValue: Tag(fourCharString: "EBLC")) // Embedded bitmap location data (bitmap-only TT fonts)
    public static let EBSC = Self(rawValue: Tag(fourCharString: "EBSC")) // Embedded bitmap scaling data (bitmap-only TT fonts)

    public static let CBDT = Self(rawValue: Tag(fourCharString: "CBDT")) // Color bitmap data
    public static let CBLC = Self(rawValue: Tag(fourCharString: "CBLC")) // Color bitmap location data

    public static let SVG_ = Self(rawValue: Tag(fourCharString: "SVG ")) // The SVG (Scalable Vector Graphics) table

    public static let COLR = Self(rawValue: Tag(fourCharString: "COLR")) // Color table
    public static let CPAL = Self(rawValue: Tag(fourCharString: "CPAL")) // Color palette table

    public static let GDEF = Self(rawValue: Tag(fourCharString: "GDEF")) // Glyph definition data          OT (opt)
    public static let GPOS = Self(rawValue: Tag(fourCharString: "GPOS")) // Glyph positioning data         OT & TT (opt)
    public static let GSUB = Self(rawValue: Tag(fourCharString: "GSUB")) // Glyph substitution data        OT (opt)
    public static let JSTF = Self(rawValue: Tag(fourCharString: "JSTF")) // Justification data             OT (opt)
    public static let MATH = Self(rawValue: Tag(fourCharString: "MATH")) // Math layout data               OT (opt)

    public static let OS_2 = Self(rawValue: Tag(fourCharString: "OS/2")) // OS/2 and Windows-specific metrics (req)
    public static let VORG = Self(rawValue: Tag(fourCharString: "VORG")) // Vertical Origin                OT only (opt)

    public static let STAT = Self(rawValue: Tag(fourCharString: "STAT")) // Style attr table (for variable fonts?) OT opt

    public static let LTSH = Self(rawValue: Tag(fourCharString: "LTSH")) // linear threshold table         TT (opt)
    public static let MERG = Self(rawValue: Tag(fourCharString: "MERG")) // Merge before antialiasing table (opt)

    public static let VDMX = Self(rawValue: Tag(fourCharString: "VDMX")) // vertical device metrics        TT (opt)
    public static let PCLT = Self(rawValue: Tag(fourCharString: "PCLT")) // PCL5 HP table (strongly discouraged) TT (opt)

    public static let bdat = Self(rawValue: Tag(fourCharString: "bdat")) // Bitmap data table
    public static let bhed = Self(rawValue: Tag(fourCharString: "bhed")) // Bitmap font header (Mac equiv to 'head' for bitmap-only TT fonts)
    public static let bloc = Self(rawValue: Tag(fourCharString: "bloc")) // Bitmap location table

    public static let bsln = Self(rawValue: Tag(fourCharString: "bsln")) // baseline table
    public static let cmap = Self(rawValue: Tag(fourCharString: "cmap")) // Character codes to glyph index mappings (req)
    public static let cvt_ = Self(rawValue: Tag(fourCharString: "cvt ")) // Control Value Table            TT (opt)
    public static let fdsc = Self(rawValue: Tag(fourCharString: "fdsc")) // font descriptors table         (opt)

    public static let evrs = Self(rawValue: Tag(fourCharString: "evrs")) // ??

    public static let feat = Self(rawValue: Tag(fourCharString: "feat")) // feature table                  AAT TT (opt)
    public static let ltag = Self(rawValue: Tag(fourCharString: "ltag")) // AAT TT (opt) OS X 10.9+ used with 'morx' & 'feat' tables

    public static let fpgm = Self(rawValue: Tag(fourCharString: "fpgm")) // Font program                   TT (opt)

    public static let fond = Self(rawValue: Tag(fourCharString: "fond")) // Mac 'FOND' resources           TT (opt)

    public static let cvar = Self(rawValue: Tag(fourCharString: "cvar")) // 'cvt ' variations table        AAT (opt)
    public static let fvar = Self(rawValue: Tag(fourCharString: "fvar")) // Font Variations Table          AAT (opt)
    public static let gvar = Self(rawValue: Tag(fourCharString: "gvar")) // Glyph Variations Table         AAT (opt)

    public static let fmtx = Self(rawValue: Tag(fourCharString: "fmtx")) // Font Metrics Table             AAT (opt)
    public static let gasp = Self(rawValue: Tag(fourCharString: "gasp")) // Grid-fitting/Scan-conversion   TT (opt)
    public static let glyf = Self(rawValue: Tag(fourCharString: "glyf")) // Glyph data                     TT (req) OT (opt)

    public static let head = Self(rawValue: Tag(fourCharString: "head")) // Font header                    (req)

    public static let hhea = Self(rawValue: Tag(fourCharString: "hhea")) // Horizontal Header              (req)
    public static let hmtx = Self(rawValue: Tag(fourCharString: "hmtx")) // Horizontal metrics             (req)

    public static let hdmx = Self(rawValue: Tag(fourCharString: "hdmx")) // Horizontal device metrics    Mac (opt)

    public static let just = Self(rawValue: Tag(fourCharString: "just")) // Justification table            AAT (opt)
    public static let lcar = Self(rawValue: Tag(fourCharString: "lcar")) // Ligature caret table           AAT (opt)

    public static let loca = Self(rawValue: Tag(fourCharString: "loca")) // Index to location              TT (req)
    public static let kern = Self(rawValue: Tag(fourCharString: "kern")) // Kerning table                  TT (opt)
    public static let kerx = Self(rawValue: Tag(fourCharString: "kerx")) // Extended Kerning table         AAT (opt)

    public static let maxp = Self(rawValue: Tag(fourCharString: "maxp")) // Maximum profile                (req)

    public static let meta = Self(rawValue: Tag(fourCharString: "meta")) // Metadata table (design lang, sup. lang) AAT (opt)
    public static let mort = Self(rawValue: Tag(fourCharString: "mort")) // Glyph Metamorphosis table (deprecated) AAT (opt)
    public static let morx = Self(rawValue: Tag(fourCharString: "morx")) // Extended Glyph Metamorphosis   AAT

    public static let name = Self(rawValue: Tag(fourCharString: "name")) // Naming table                   (req)
    public static let opbd = Self(rawValue: Tag(fourCharString: "opbd")) // Optical bounds table           AAT (opt)

    public static let post = Self(rawValue: Tag(fourCharString: "post")) // PostScript information         (req)
    public static let prep = Self(rawValue: Tag(fourCharString: "prep")) // CV Program                     TT (opt)
    public static let prop = Self(rawValue: Tag(fourCharString: "prop")) // Glyph Properties table

    public static let sbix = Self(rawValue: Tag(fourCharString: "sbix")) // Standard graphics format bitmap data (full color) (Apple-only?)
    public static let trak = Self(rawValue: Tag(fourCharString: "trak")) // Tracking table                 AAT (opt)

    public static let vhea = Self(rawValue: Tag(fourCharString: "vhea")) // Vertical header table          TT (opt)
    public static let vmtx = Self(rawValue: Tag(fourCharString: "vmtx")) // Vertical metrics table         TT (opt)

    public static let Zapf = Self(rawValue: Tag(fourCharString: "Zapf")) //                                AAT (opt)

    public var fourCharString: String {
        return rawValue.fourCharString
    }

    public var byteSwapped: TableTag {
        return .init(rawValue: rawValue.byteSwapped)
    }

    public var description: String {
        return fourCharString
    }

    public static func < (lhs: TableTag, rhs: TableTag) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    public static func == (lhs: TableTag, rhs: TableTag) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

@objc public enum PlatformID: UInt16, Comparable, CustomStringConvertible {
    case unicode    = 0
    case mac        = 1
    case iso        = 2 // deprecated/reserved
    case microsoft  = 3
    case custom     = 4
    case any        = 0xFFFF // mine

    public static func < (lhs: PlatformID, rhs: PlatformID) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    public static func == (lhs: PlatformID, rhs: PlatformID) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public var description: String {
        switch self {
            case .unicode:      return NSLocalizedString("Unicode", comment: "")
            case .mac:          return NSLocalizedString("Mac", comment: "")
            case .iso:          return NSLocalizedString("ISO/Reserved", comment: "")
            case .microsoft:    return NSLocalizedString("Microsoft", comment: "")
            case .custom:       return NSLocalizedString("Custom", comment: "")
            case .any:          return NSLocalizedString("<any>", comment: "")
        }
    }
}

@objc public enum UnicodeEncodingID: UInt16, Comparable, CustomStringConvertible {
    case unicode1_0             = 0  // Unicode 1.0 semantics.
    case unicode1_1             = 1  // Unicode 1.1 semantics.
    case iso_10646              = 2  // ISO/IEC 10646 semantics. (deprecated)
    case unicode2_0_UTF16_BMP   = 3  // Unicode 2.0 and onwards, Unicode BMP only (cmap subt. formats 0, 4, 6).
    case unicode2_0_UTF32       = 4  // Unicode 2.0 and onwards, Unicode full rep (UCS-4) (cmap subt. formats 0, 4, 6, 10, 12).
    // the following are for 'cmap's only, not for use in 'name' table:
    case unicodeUVS             = 5  // Unicode Variation Sequences (cmap subtable format 14). */
    case unicodeFullRepertoire  = 6  // Unicode full repertoire (cmap subtable formats 0, 4, 6, 10, 12, 13).
                                     // NOTE: Apple defines 6 as Last Resort, but that's unused.

    public static func < (lhs: UnicodeEncodingID, rhs: UnicodeEncodingID) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    public static func == (lhs: UnicodeEncodingID, rhs: UnicodeEncodingID) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public var description: String {
        switch self {
            case .unicode1_0: return NSLocalizedString("Unicode 1.0 semantics", comment: "")
            case .unicode1_1: return NSLocalizedString("Unicode 1.1 semantics", comment: "")
            case .iso_10646: return NSLocalizedString("ISO 10646 semantics", comment: "")
            case .unicode2_0_UTF16_BMP: return NSLocalizedString("Unicode 2.0 UTF-16 BMP", comment: "")
            case .unicode2_0_UTF32: return NSLocalizedString("Unicode 2.0 UTF-32", comment: "")
            case .unicodeUVS: return NSLocalizedString("Unicode Variation Sequences", comment: "")
            case .unicodeFullRepertoire: return NSLocalizedString("Unicode full repertoire.", comment: "")
        }
    }
}

// MacScriptID & MacLanguageID are in CoreFontTypes.swift

@objc public enum MicrosoftEncodingID : UInt16, Comparable, CustomStringConvertible {
    case symbol                 = 0
    case unicodeBMP             = 1 // UTF-16
    case shiftJIS               = 2
    case prc                    = 3
    case big5                   = 4
    case wansung                = 5
    case johab                  = 6
    case unicodeUCS4            = 10 // UCS-4/UTF-32

    public static func < (lhs: MicrosoftEncodingID, rhs: MicrosoftEncodingID) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    public static func == (lhs: MicrosoftEncodingID, rhs: MicrosoftEncodingID) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public var description: String {
        switch self {
            case .symbol:          return NSLocalizedString("Symbol", comment: "")
            case .unicodeBMP:      return NSLocalizedString("Unicode BMP", comment: "")
            case .shiftJIS:        return NSLocalizedString("Shift-JIS", comment: "")
            case .prc:             return NSLocalizedString("PRC", comment: "")
            case .big5:            return NSLocalizedString("Big5", comment: "")
            case .wansung:         return NSLocalizedString("Wansung", comment: "")
            case .johab:           return NSLocalizedString("Johab", comment: "")
            case .unicodeUCS4:     return NSLocalizedString("Unicode UCS-4/UTF-32", comment: "")
        }
    }
}

@objc public enum MicrosoftLanguageID: UInt16, Comparable, CustomStringConvertible {
    case arabicSaudiArabia          = 1025	// 0x0401
    case bulgarian                  = 1026	// 0x0402
    case catalan                    = 1027	// 0x0403
    case chineseTaiwan              = 1028	// 0x0404
    case czech                      = 1029	// 0x0405
    case danish                     = 1030	// 0x0406
    case german                     = 1031	// 0x0407
    case greek                      = 1032  // 0x0408
    case englishAmerican            = 1033  // 0x0409
    case spanishTraditional         = 1034  // 0x040a
    case finnish                    = 1035  // 0x040b
    case french                     = 1036  // 0x040c
    case hebrew                     = 1037  // 0x040d
    case hungarian                  = 1038  // 0x040e
    case icelandic                  = 1039  // 0x040f
    case italian                    = 1040  // 0x0410
    case japanese                   = 1041  // 0x0411
    case korean                     = 1042  // 0x0412
    case dutch                      = 1043  // 0x0413
    case norwegianBokmal            = 1044  // 0x0414
    case polish                     = 1045  // 0x0415
    case portugueseBrazillian       = 1046  // 0x0416
    case romanshSwitzerland         = 1047  // 0x0417
    case romanian                   = 1048  // 0x0418
    case russian                    = 1049  // 0x0419
    case croatian                   = 1050  // 0x041a,
    case slovak                     = 1051  // 0x041b,
    case albanian                   = 1052  // 0x041c,
    case swedish                    = 1053  // 0x041d,
    case thai                       = 1054  // 0x041e
    case turkish                    = 1055  // 0x041f
    case urdu                       = 1056  // 0x0420
    case indonesian                 = 1057  // 0x0421
    case ukranian                   = 1058  // 0x0422
    case byelorussian               = 1059  // 0x0423
    case slovenian                  = 1060  // 0x0424
    case estonian                   = 1061  // 0x0425
    case latvian                    = 1062  // 0x0426
    case lithuanian                 = 1063  // 0x0427
    case tajik                      = 1064  // 0x0428
    case vietnamese                 = 1066  // 0x042a
    case armenian                   = 1067  // 0x042b
    case azeri                      = 1068  // 0x042c
    case basque                     = 1069  // 0x042d
    case upperSorbian               = 1070  // 0x042e
    case macedonian                 = 1071  // 0x042f
    case malay                      = 1086  // 0x043e
    case chinesePRC                 = 0x0804
    case germanSwiss                = 0x0807
    case englishBritish             = 0x0809
    case spanishMexican             = 0x080a
    case frenchBelgian              = 0x080c
    case italianSwiss               = 0x0810
    case belgianFlemish             = 0x0813
    case norwegianNynorsk           = 0x0814
    case portuguese                 = 0x0816
    case arabicEgypt                = 0x0c01 // 3073
    case chineseHongKong            = 0x0c04 // 3076
    case germanAustrian             = 0x0c07
    case englishAustralian          = 0x0c09
    case spanishModern              = 0x0c0a
    case frenchCanadian             = 0x0c0c
    case chineseSingapore           = 0x1004
    case germanLuxembourg           = 0x1007
    case englishCanadian            = 0x1009
    case frenchSwiss                = 0x100c
    case germanLiechtenstein        = 0x1407
    case englishNewZealand          = 0x1409
    case frenchLuxembourg           = 0x140c
    case englishIreland             = 0x1809

    public static func < (lhs: MicrosoftLanguageID, rhs: MicrosoftLanguageID) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    public static func == (lhs: MicrosoftLanguageID, rhs: MicrosoftLanguageID) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public var description: String {
        switch self {
            case .arabicSaudiArabia: return NSLocalizedString("Arabic (Saudi Arabia)", comment: "")
            case .bulgarian: return NSLocalizedString("Bulgarian", comment: "")
            case .catalan: return NSLocalizedString("Catalan", comment: "")
            case .chineseTaiwan: return NSLocalizedString("Chinese (Taiwan)", comment: "")
            case .czech: return NSLocalizedString("Czech", comment: "")
            case .danish: return NSLocalizedString("Danish", comment: "")
            case .german: return NSLocalizedString("German", comment: "")
            case .greek: return NSLocalizedString("Greek", comment: "")
            case .englishAmerican: return NSLocalizedString("English (American)", comment: "")
            case .spanishTraditional: return NSLocalizedString("Spanish (Traditional)", comment: "")
            case .finnish: return NSLocalizedString("Finnish", comment: "")
            case .french: return NSLocalizedString("French", comment: "")
            case .hebrew: return NSLocalizedString("Hebrew", comment: "")
            case .hungarian: return NSLocalizedString("Hungarian", comment: "")
            case .icelandic: return NSLocalizedString("Icelandic", comment: "")
            case .italian: return NSLocalizedString("Italian", comment: "")
            case .japanese: return NSLocalizedString("Japanese", comment: "")
            case .korean: return NSLocalizedString("Korean", comment: "")
            case .dutch: return NSLocalizedString("Dutch", comment: "")
            case .norwegianBokmal: return NSLocalizedString("Norwegian (Bokmal)", comment: "")
            case .polish: return NSLocalizedString("Polish", comment: "")
            case .portugueseBrazillian: return NSLocalizedString("Portuguese (Brazilian)", comment: "")
            case .romanshSwitzerland: return NSLocalizedString("Romansh (Switzerland)", comment: "")
            case .romanian: return NSLocalizedString("Romanian", comment: "")
            case .russian: return NSLocalizedString("Russian", comment: "")
            case .croatian: return NSLocalizedString("Croatian", comment: "")
            case .slovak: return NSLocalizedString("Slovak", comment: "")
            case .albanian: return NSLocalizedString("Albanian", comment: "")
            case .swedish: return NSLocalizedString("Swedish", comment: "")
            case .thai: return NSLocalizedString("Thai", comment: "")
            case .turkish: return NSLocalizedString("Turkish", comment: "")
            case .urdu: return NSLocalizedString("Urdu", comment: "")
            case .indonesian: return NSLocalizedString("Indonesian", comment: "")
            case .ukranian: return NSLocalizedString("Ukrainian", comment: "")
            case .byelorussian: return NSLocalizedString("Byelorussian", comment: "")
            case .slovenian: return NSLocalizedString("Slovenian", comment: "")
            case .estonian: return NSLocalizedString("Estonian", comment: "")
            case .latvian: return NSLocalizedString("Latvian", comment: "")
            case .lithuanian: return NSLocalizedString("Lithuanian", comment: "")
            case .tajik: return NSLocalizedString("Tajik", comment: "")
            case .vietnamese: return NSLocalizedString("Vietnamese", comment: "")
            case .armenian: return NSLocalizedString("Armenian", comment: "")
            case .azeri: return NSLocalizedString("Azeri", comment: "")
            case .basque: return NSLocalizedString("Basque", comment: "")
            case .upperSorbian: return NSLocalizedString("Upper Sorbian", comment: "")
            case .macedonian: return NSLocalizedString("Macedonian", comment: "")
            case .malay: return NSLocalizedString("Malay", comment: "")
            case .chinesePRC: return NSLocalizedString("Chinese (PRC)", comment: "")
            case .germanSwiss: return NSLocalizedString("German (Switzerland)", comment: "")
            case .englishBritish: return NSLocalizedString("English (British)", comment: "")
            case .spanishMexican: return NSLocalizedString("Spanish (Mexican)", comment: "")
            case .frenchBelgian: return NSLocalizedString("French (Belgian)", comment: "")
            case .italianSwiss: return NSLocalizedString("Italian (Switzerland)", comment: "")
            case .belgianFlemish: return NSLocalizedString("Belgian (Flemish)", comment: "")
            case .norwegianNynorsk: return NSLocalizedString("Norwegian (Nynorsk)", comment: "")
            case .portuguese: return NSLocalizedString("Portuguese", comment: "")
            case .arabicEgypt: return NSLocalizedString("Arabic (Egypt)", comment: "")
            case .chineseHongKong: return NSLocalizedString("Chinese (Hong Kong)", comment: "")
            case .germanAustrian: return NSLocalizedString("German (Austrian)", comment: "")
            case .englishAustralian: return NSLocalizedString("English (Australian)", comment: "")
            case .spanishModern: return NSLocalizedString("Spanish (Modern)", comment: "")
            case .frenchCanadian: return NSLocalizedString("French (Canadian)", comment: "")
            case .chineseSingapore: return NSLocalizedString("Chinese (Singapore)", comment: "")
            case .germanLuxembourg: return NSLocalizedString("German (Luxembourg)", comment: "")
            case .englishCanadian: return NSLocalizedString("English (Canadian)", comment: "")
            case .frenchSwiss: return NSLocalizedString("French (Switzerland)", comment: "")
            case .germanLiechtenstein: return NSLocalizedString("German (Liechtenstein)", comment: "")
            case .englishNewZealand: return NSLocalizedString("English (New Zealand)", comment: "")
            case .frenchLuxembourg: return NSLocalizedString("French (Luxembourg)", comment: "")
            case .englishIreland: return NSLocalizedString("English (Ireland)", comment: "")
        }
    }
}

public enum EncodingID: Comparable, CustomStringConvertible {
	case unicode(UnicodeEncodingID)
	case mac(MacScriptID)
	case microsoft(MicrosoftEncodingID)
    case any

    public var rawValue: UInt16 {
        switch self {
            case .unicode(let encID):
                return encID.rawValue
            case .mac(let encID):
                return encID.rawValue
            case .microsoft(let encID):
                return encID.rawValue
            case .any:
                return 0
        }
    }

    public static func encodingIDWith(platformID: PlatformID, encodingID: UInt16) throws -> EncodingID {
        switch platformID {
            case .unicode:
                guard let encID = UnicodeEncodingID(rawValue: encodingID) else {
                    throw FontTableError.parseError("Unknown Unicode encoding ID: \(encodingID)")
                }
                return .unicode(encID)
            case .mac:
                guard let encID = MacScriptID(rawValue: encodingID) else {
                    throw FontTableError.parseError("Unknown MacScript encoding ID: \(encodingID)")
                }
                return .mac(encID)
            case .microsoft:
                guard let encID = MicrosoftEncodingID(rawValue: encodingID) else {
                    throw FontTableError.parseError("Unknown Microsoft encoding ID: \(encodingID)")
                }
                return .microsoft(encID)
            case .iso, .custom, .any:
                throw FontTableError.parseError("Unsupported platform ID: \(platformID.rawValue)")
        }
    }

    public var description: String {
        switch self {
            case .unicode(let encID):
                return encID.description
            case .mac(let encID):
                return encID.description
            case .microsoft(let encID):
                return encID.description
            case .any:
                return NSLocalizedString("Any", comment: "")
        }
    }
}

public enum LanguageID: Comparable, CustomStringConvertible {
    case unicode
    case mac(MacLanguageID)
    case microsoft(MicrosoftLanguageID)
    case any

    public var rawValue: UInt16 {
        switch self {
            case .mac(let langID):
                return langID.rawValue
            case .microsoft(let langID):
                return langID.rawValue
            case .any, .unicode:
                return 0
        }
    }
    
    public static func languageIDWith(platformID: PlatformID, languageID: UInt16) throws -> LanguageID {
        switch platformID {
            case .unicode:
                return .unicode
            case .mac:
                guard let langID = MacLanguageID(rawValue: languageID) else {
                    throw FontTableError.parseError("Unknown MacLanguage ID: \(languageID)")
                }
                return .mac(langID)
            case .microsoft:
                guard let langID = MicrosoftLanguageID(rawValue: languageID) else {
                    throw FontTableError.parseError("Unknown Microsoft language ID: \(languageID)")
                }
                return .microsoft(langID)
            case .custom, .iso, .any:
                throw FontTableError.parseError("Unsupported platform ID: \(platformID.rawValue)")
        }
    }

    public var description: String {
        switch self {
            case .unicode:
                return NSLocalizedString("--", comment: "")
            case .mac(let langID):
                return langID.description
            case .microsoft(let langID):
                return langID.description
            case .any:
                return NSLocalizedString("Any", comment: "")
        }
    }
}

public extension FontTable_name {
    enum FontNameID: Comparable, CustomStringConvertible {
        case copyright                 // = 0
        case family                    // = 1
        case subfamily                 // = 2
        case unique                    // = 3
        case full                      // = 4
        case version                   // = 5
        case postscript                // = 6   // 63 char len; ASCII subset, codes 33-126, except for the 10 characters [](){}<>/%
        case trademark                 // = 7
        case manufacturer              // = 8
        case designer                  // = 9
        case description               // = 10
        case vendorURL                 // = 11
        case designerURL               // = 12
        case licenseDescription        // = 13
        case licenseInfoURL            // = 14
        case reserved                  // = 15
        case typographicFamily         // = 16
        case typographicSubfamily      // = 17
        case macCompatibleFull         // = 18
        case sampleText                // = 19
        case postScriptCID             // = 20  // 63 char len; ASCII subset, codes 33-126, except for the 10 characters [](){}<>/%
        case wwsFamily                 // = 21  // Weight-Width-Slope; fsSelection WWS field
        case wwsSubfamily              // = 22  // Weight-Width-Slope; fsSelection WWS field
        case lightBackgroundPalette    // = 23
        case darkBackgroundPalette     // = 24
        case varsPostScriptNamePrefix  // = 25
        case lastReserved              // = 255
        case custom(UInt16)            // custom names above 255 can be referenced in other tables like `feat`
        case any                       // = 0xffff

        public init(rawValue: UInt16) {
            if let nameID = Self.rawValuesToCases[rawValue] {
                self = nameID
            } else {
                self = .custom(rawValue)
            }
        }

        public var rawValue: UInt16 {
            switch self {
                case .copyright:                return 0
                case .family:                   return 1
                case .subfamily:                return 2
                case .unique:                   return 3
                case .full:                     return 4
                case .version:                  return 5
                case .postscript:               return 6
                case .trademark:                return 7
                case .manufacturer:             return 8
                case .designer:                 return 9
                case .description:              return 10
                case .vendorURL:                return 11
                case .designerURL:              return 12
                case .licenseDescription:       return 13
                case .licenseInfoURL:           return 14
                case .reserved:                 return 15
                case .typographicFamily:        return 16
                case .typographicSubfamily:     return 17
                case .macCompatibleFull:        return 18
                case .sampleText:               return 19
                case .postScriptCID:            return 20
                case .wwsFamily:                return 21
                case .wwsSubfamily:             return 22
                case .lightBackgroundPalette:   return 23
                case .darkBackgroundPalette:    return 24
                case .varsPostScriptNamePrefix: return 25
                case .lastReserved:             return 255
                case .custom(let v):            return UInt16(v)
                case .any:                      return 0xffff
            }
        }
        public static func < (lhs: FontNameID, rhs: FontNameID) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
        public static func == (lhs: FontNameID, rhs: FontNameID) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }

        public var description: String {
            switch self {
                case .copyright:                return NSLocalizedString("Copyright", comment: "")
                case .family:                   return NSLocalizedString("Family", comment: "")
                case .subfamily:                return NSLocalizedString("Subfamily", comment: "")
                case .unique:                   return NSLocalizedString("Unique", comment: "")
                case .full:                     return NSLocalizedString("Full", comment: "")
                case .version:                  return NSLocalizedString("Version", comment: "")
                case .postscript:               return NSLocalizedString("Postscript", comment: "")
                case .trademark:                return NSLocalizedString("Trademark", comment: "")
                case .manufacturer:             return NSLocalizedString("Manufacturer", comment: "")
                case .designer:                 return NSLocalizedString("Designer", comment: "")
                case .description:              return NSLocalizedString("Description", comment: "")
                case .vendorURL:                return NSLocalizedString("Vendor URL", comment: "")
                case .designerURL:              return NSLocalizedString("Designer URL", comment: "")
                case .licenseDescription:       return NSLocalizedString("License Description", comment: "")
                case .licenseInfoURL:           return NSLocalizedString("License Info URL", comment: "")
                case .reserved:                 return NSLocalizedString("Reserved", comment: "")
                case .typographicFamily:        return NSLocalizedString("Typographic Family", comment: "")
                case .typographicSubfamily:     return NSLocalizedString("Typographic Subfamily", comment: "")
                case .macCompatibleFull:        return NSLocalizedString("Mac-Compatible Full", comment: "")
                case .sampleText:               return NSLocalizedString("Sample Text", comment: "")
                case .postScriptCID:            return NSLocalizedString("PostScript CID", comment: "")
                case .wwsFamily:                return NSLocalizedString("WWS Family", comment: "")
                case .wwsSubfamily:             return NSLocalizedString("WWS Subfamily", comment: "")
                case .lightBackgroundPalette:   return NSLocalizedString("Light Background Palette", comment: "")
                case .darkBackgroundPalette:    return NSLocalizedString("Dark Background Palette", comment: "")
                case .varsPostScriptNamePrefix: return NSLocalizedString("Variations PostScript Name Prefix", comment: "")
                case .lastReserved:             return NSLocalizedString("lastReserved", comment: "")
                case .any:                      return NSLocalizedString("any", comment: "")
                case .custom(let v):            return NSLocalizedString("<\(v)>", comment: "")
            }
        }

        fileprivate static let rawValuesToCases: [UInt16: FontNameID] =
        [
            0: .copyright,
            1: .family,
            2: .subfamily,
            3: .unique,
            4: .full,
            5: .version,
            6: .postscript,
            7: .trademark,
            8: .manufacturer,
            9: .designer,
            10: .description,
            11: .vendorURL,
            12: .designerURL,
            13: .licenseDescription,
            14: .licenseInfoURL,
            15: .reserved,
            16: .typographicFamily,
            17: .typographicSubfamily,
            18: .macCompatibleFull,
            19: .sampleText,
            20: .postScriptCID,
            21: .wwsFamily,
            22: .wwsSubfamily,
            23: .lightBackgroundPalette,
            24: .darkBackgroundPalette,
            25: .varsPostScriptNamePrefix,
            255: .lastReserved,
            0xffff: .any,
        ]
    }
}

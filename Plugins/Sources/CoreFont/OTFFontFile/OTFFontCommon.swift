//
//  OTFFontCommon.swift
//  CoreFont
//
//  Created by Mark Douma on 1/10/2026.
//

import Foundation
import RFSupport

public typealias GlyphID   = UInt16
public typealias GlyphID32 = UInt32

public extension GlyphID {
    static let notDef:      GlyphID = 0x0000        /// GID of `.notdef` glyph
}

public extension GlyphID32 {
    static let notDef:      GlyphID32 = 0x00000000  /// GID of `.notdef` glyph
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

    public static let `true`:  OTFsfntFormat = .init(rawValue: UInt32(fourCharString: "true"))  /// for TT; Apple; prefer `.V1_0` for better cross-platform support
    public static let OTTO:    OTFsfntFormat = .init(rawValue: UInt32(fourCharString: "OTTO"))  /// for 'CFF '/'CFF2' outline data
    public static let typ1:    OTFsfntFormat = .init(rawValue: UInt32(fourCharString: "typ1"))
    public static let V1_0:    OTFsfntFormat = .init(rawValue: 0x00010000)                      /// standard TT outline/bitmap
    public static let ttcf:    OTFsfntFormat = .init(rawValue: UInt32(fourCharString: "ttcf"))
    public static let _kbd:    OTFsfntFormat = .init(rawValue: 0xA56B6264) // '•kbd'    .Keyboard
    public static let _lst:    OTFsfntFormat = .init(rawValue: 0xA56C7374) // '•lst'    .LastResort
    public static let vt10:    OTFsfntFormat = .init(rawValue: 0x35ECFAA2) // VT100
    public static let vt1b:    OTFsfntFormat = .init(rawValue: 0x498182F0) // VT100-Bold
}

@objc public enum LocaOffsetFormat: Int16 {
    case short = 0  /// entries in the `loca` table should be multiplied by 2 to get actual byte offsets into `glyf` data
    case long  = 1  /// entries in the `loca` table represent actualy byte offsets into the `glyf` data
}

/// gives glyphs/components a chance to resolve metrics and compound/composite glyph references once the font is set up
public protocol FontAwaking {
    func awakeFromFont()
}

public func OTFReWritingOrderSort(lhs: TableTag, rhs: TableTag) -> Bool {
    let a = ttfRewriteOrder[lhs] ?? Int.max
    let b = ttfRewriteOrder[rhs] ?? Int.max
    if a != b { return a < b }
    return lhs < rhs
}

private let ttfRewriteOrder: [TableTag: Int] = [
    .cmap: 1,
    .OS_2: 2,
    .glyf: 3, // creates/tweaks 'loca', 'hmtx'; could tweak 'head'
    .loca: 4, // could tweak 'head' during 'CFF ' to 'glyf'
    .post: 5,
    .maxp: 6, // tweaks 'head'
    .feat: 7,
    .name: 8,
    .head: 9,
    .hmtx: 10,
    .hhea: 11,
    .vmtx: 12,
    .vhea: 13,
]

public struct TableTag: RawRepresentable, Comparable, Hashable, CaseIterable, CustomStringConvertible, CustomDebugStringConvertible {
    public let rawValue: Tag

    public init(rawValue: Tag) {
        self.rawValue = rawValue
    }

    /// Key: `OT`: OpenType (with PostScript-type outlines in `CFF ` or `CFF2` table)
    ///      `TT`: TrueType (with TrueType-type outlines in `glyf` table)
    ///      `AAT`: an Apple-only table that offers advanced features
    /// In general, tags with all four lowercase letters are reserved for Apple.
    ///
    /// - Note: Microsoft bitmap fonts use `head`, `EBDT`, `EBLC`, and optionally `EBSC`
    ///         Apple bitmap fonts use `bhed`, `bdat`, `bloc`, and optionally `EBSC`

    /// Baseline data table (opt)
    public static let BASE = TableTag(rawValue: Tag(fourCharString: "BASE"))

    /// Compact Font Format 1.0        OT (req)
    public static let CFF_ = TableTag(rawValue: Tag(fourCharString: "CFF "))

    /// Compact Font Format 2.0        OT (req)
    public static let CFF2 = TableTag(rawValue: Tag(fourCharString: "CFF2"))

    /// digital signature (opt)
    public static let DSIG = TableTag(rawValue: Tag(fourCharString: "DSIG"))

    /// ?
    public static let TYP1 = TableTag(rawValue: Tag(fourCharString: "TYP1"))

    /// ?
    public static let CID_ = TableTag(rawValue: Tag(fourCharString: "CID "))

    /// glyphIDs to CMap CIDs table    TT (opt)
    public static let gcid = TableTag(rawValue: Tag(fourCharString: "gcid"))

    ///
    public static let BLND = TableTag(rawValue: Tag(fourCharString: "BLND"))

    /// Embedded bitmap data (B&W/grayscale) (bitmap-only TT fonts)
    /// Microsoft's identical equivalent to Apple's `bdat` table
    public static let EBDT = TableTag(rawValue: Tag(fourCharString: "EBDT"))

    /// Embedded bitmap location data (bitmap-only TT fonts)
    /// Microsoft's identical equivalent to Apple's `bloc` table
    public static let EBLC = TableTag(rawValue: Tag(fourCharString: "EBLC"))

    /// Embedded bitmap scaling data (MS-only, bitmap-only TT fonts, optional)
    public static let EBSC = TableTag(rawValue: Tag(fourCharString: "EBSC"))

    /// Color bitmap data
    public static let CBDT = TableTag(rawValue: Tag(fourCharString: "CBDT"))

    /// Color bitmap location data
    public static let CBLC = TableTag(rawValue: Tag(fourCharString: "CBLC"))

    /// The SVG (Scalable Vector Graphics) table
    public static let SVG_ = TableTag(rawValue: Tag(fourCharString: "SVG "))

    /// Color table
    public static let COLR = TableTag(rawValue: Tag(fourCharString: "COLR"))

    /// Color palette table
    public static let CPAL = TableTag(rawValue: Tag(fourCharString: "CPAL"))

    /// Glyph definition data          OT (opt)
    public static let GDEF = TableTag(rawValue: Tag(fourCharString: "GDEF"))

    /// Glyph positioning data         OT & TT (opt)
    public static let GPOS = TableTag(rawValue: Tag(fourCharString: "GPOS"))

    /// Glyph substitution data        OT (opt)
    public static let GSUB = TableTag(rawValue: Tag(fourCharString: "GSUB"))

    /// Justification data             OT (opt)
    public static let JSTF = TableTag(rawValue: Tag(fourCharString: "JSTF"))

    /// Math layout data               OT (opt)
    public static let MATH = TableTag(rawValue: Tag(fourCharString: "MATH"))

    /// `OS/2` and Windows-specific metrics (Windows: req, Apple: opt)
    public static let OS_2 = TableTag(rawValue: Tag(fourCharString: "OS/2"))

    /// Vertical Origin                OT only (opt)
    public static let VORG = TableTag(rawValue: Tag(fourCharString: "VORG"))

    /// Style attr table (for variable fonts?) OT opt
    public static let STAT = TableTag(rawValue: Tag(fourCharString: "STAT"))

    /// linear threshold table         TT (opt)
    public static let LTSH = TableTag(rawValue: Tag(fourCharString: "LTSH"))

    /// Merge before antialiasing table (opt)
    public static let MERG = TableTag(rawValue: Tag(fourCharString: "MERG"))

    /// vertical device metrics        TT (opt)
    public static let VDMX = TableTag(rawValue: Tag(fourCharString: "VDMX"))

    /// PCL5 HP table (strongly discouraged) TT (opt)
    public static let PCLT = TableTag(rawValue: Tag(fourCharString: "PCLT"))

    /// Accent attachment table (Apple, deprecated)
    public static let acnt = TableTag(rawValue: Tag(fourCharString: "acnt"))

    /// Anchor point table      AAT (opt) 10.9+
    public static let ankr = TableTag(rawValue: Tag(fourCharString: "ankr"))

    /// Bitmap data table (Apple equiv to MS `EBDT`; req for bitmap-only)
    public static let bdat = TableTag(rawValue: Tag(fourCharString: "bdat"))

    /// Bitmap font header (Apple equiv to `head`; req for bitmap-only)
    public static let bhed = TableTag(rawValue: Tag(fourCharString: "bhed"))

    /// Bitmap location table (Apple equiv to MS `EBLC`; req for bitmap-only)
    public static let bloc = TableTag(rawValue: Tag(fourCharString: "bloc"))

    /// baseline table          AAT (opt)
    public static let bsln = TableTag(rawValue: Tag(fourCharString: "bsln"))

    /// Character codes to glyph index mappings (req)
    public static let cmap = TableTag(rawValue: Tag(fourCharString: "cmap"))

    /// Control Value Table            TT (opt)
    public static let cvt_ = TableTag(rawValue: Tag(fourCharString: "cvt "))

    /// font descriptors table         (opt)
    public static let fdsc = TableTag(rawValue: Tag(fourCharString: "fdsc"))

    /// ??
    public static let evrs = TableTag(rawValue: Tag(fourCharString: "evrs"))

    /// feature table                  AAT TT (opt)
    public static let feat = TableTag(rawValue: Tag(fourCharString: "feat"))

    /// AAT TT (opt) OS X 10.9+ used with `morx` & `feat` tables
    public static let ltag = TableTag(rawValue: Tag(fourCharString: "ltag"))

    /// Font program                   TT (opt)
    public static let fpgm = TableTag(rawValue: Tag(fourCharString: "fpgm"))

    /// Apple `FOND` (& `NFNT`) resources TT (opt)
    public static let fond = TableTag(rawValue: Tag(fourCharString: "fond"))

    /// axis variations table          AAT (opt)
    public static let avar = TableTag(rawValue: Tag(fourCharString: "avar"))

    /// `cvt ` variations table        AAT (opt)
    public static let cvar = TableTag(rawValue: Tag(fourCharString: "cvar"))

    /// Font Variations Table          AAT (opt)
    public static let fvar = TableTag(rawValue: Tag(fourCharString: "fvar"))

    /// Glyph Variations Table         AAT (opt)
    public static let gvar = TableTag(rawValue: Tag(fourCharString: "gvar"))

    /// Font Metrics Table             AAT (opt)
    public static let fmtx = TableTag(rawValue: Tag(fourCharString: "fmtx"))

    /// Grid-fitting/Scan-conversion   TT (opt)
    public static let gasp = TableTag(rawValue: Tag(fourCharString: "gasp"))

    /// Glyph data   TT (req) OT (opt)
    public static let glyf = TableTag(rawValue: Tag(fourCharString: "glyf"))

    /// Font header (req)
    public static let head = TableTag(rawValue: Tag(fourCharString: "head"))

    /// Horizontal Header (req)
    public static let hhea = TableTag(rawValue: Tag(fourCharString: "hhea"))

    /// Horizontal Metrics (req)
    public static let hmtx = TableTag(rawValue: Tag(fourCharString: "hmtx"))

    /// Horizontal device metrics    Apple (opt)
    public static let hdmx = TableTag(rawValue: Tag(fourCharString: "hdmx"))

    /// Hierarchical Variation Fonts  AAT (opt) macOS 15.6+
    public static let hvgl = TableTag(rawValue: Tag(fourCharString: "hvgl"))

    /// Hierarchical Variation Fonts  (used w/ `hvgl`) AAT (opt)
    public static let hvpm = TableTag(rawValue: Tag(fourCharString: "hvpm"))

    /// Justification table            AAT (opt)
    public static let just = TableTag(rawValue: Tag(fourCharString: "just"))

    /// Ligature caret table           AAT (opt)
    public static let lcar = TableTag(rawValue: Tag(fourCharString: "lcar"))

    /// Index to location              TT (req)
    public static let loca = TableTag(rawValue: Tag(fourCharString: "loca"))

    /// Kerning table                  TT (opt)
    public static let kern = TableTag(rawValue: Tag(fourCharString: "kern"))

    /// Extended Kerning table         AAT (opt)
    public static let kerx = TableTag(rawValue: Tag(fourCharString: "kerx"))

    /// Maximum profile             OT & TT (req)
    public static let maxp = TableTag(rawValue: Tag(fourCharString: "maxp"))

    /// Metadata table (design lang, sup. lang) AAT (opt)
    public static let meta = TableTag(rawValue: Tag(fourCharString: "meta"))

    /// Glyph Metamorphosis table (deprecated) AAT (opt)
    public static let mort = TableTag(rawValue: Tag(fourCharString: "mort"))

    /// Extended Glyph Metamorphosis   AAT (opt)
    public static let morx = TableTag(rawValue: Tag(fourCharString: "morx"))

    /// Naming table                OT & TT (req)
    public static let name = TableTag(rawValue: Tag(fourCharString: "name"))

    /// Optical bounds table           AAT (opt)
    public static let opbd = TableTag(rawValue: Tag(fourCharString: "opbd"))

    /// PostScript information      OT & TT (req)
    public static let post = TableTag(rawValue: Tag(fourCharString: "post"))

    /// CV Program                     TT (opt)
    public static let prep = TableTag(rawValue: Tag(fourCharString: "prep"))

    /// Glyph Properties table        AAT (opt)
    public static let prop = TableTag(rawValue: Tag(fourCharString: "prop"))

    /// Standard graphics format bitmap data (full color) (Apple-only?)
    public static let sbix = TableTag(rawValue: Tag(fourCharString: "sbix"))

    /// Tracking table                AAT (opt)
    public static let trak = TableTag(rawValue: Tag(fourCharString: "trak"))

    /// Vertical header table          TT (opt)
    public static let vhea = TableTag(rawValue: Tag(fourCharString: "vhea"))

    /// Vertical metrics table         TT (opt)
    public static let vmtx = TableTag(rawValue: Tag(fourCharString: "vmtx"))

    /// cross-reference table         AAT (opt)
    public static let xref = TableTag(rawValue: Tag(fourCharString: "xref"))

    ///                                AAT (opt)
    public static let Zapf = TableTag(rawValue: Tag(fourCharString: "Zapf"))

    public var fourCharString: String {
        return rawValue.fourCharString
    }

    public var byteSwapped: TableTag {
        return .init(rawValue: rawValue.byteSwapped)
    }

    public var description: String {
        switch self {
            case .BASE: return NSLocalizedString("Baseline table", comment: "")
            case .CFF_: return NSLocalizedString("Compact Font Format v1 table", comment: "")
            case .CFF2: return NSLocalizedString("Compact Font Format v2 table", comment: "")
            case .DSIG: return NSLocalizedString("Digital Signature", comment: "")
            case .gcid: return NSLocalizedString("Character-to-CID Mapping table", comment: "")
            case .EBDT: return NSLocalizedString("Embedded Bitmap Data table", comment: "")
            case .EBLC: return NSLocalizedString("Embedded Bitmap Location table", comment: "")
            case .EBSC: return NSLocalizedString("Embedded Bitmap Scaling table", comment: "")
            case .CBDT: return NSLocalizedString("Color Bitmap Data table", comment: "")
            case .CBLC: return NSLocalizedString("Color Bitmap Location table", comment: "")
            case .SVG_: return NSLocalizedString("Scalable Vector Graphics table", comment: "")
            case .COLR: return NSLocalizedString("Color table", comment: "")
            case .CPAL: return NSLocalizedString("Palette table", comment: "")
            case .GDEF: return NSLocalizedString("Glyph Definition table", comment: "")
            case .GPOS: return NSLocalizedString("Glyph Positioning table", comment: "")
            case .GSUB: return NSLocalizedString("Glyph Substitution table", comment: "")
            case .JSTF: return NSLocalizedString("Justification table", comment: "")
            case .MATH: return NSLocalizedString("Mathematical Typesetting table", comment: "")
            case .OS_2: return NSLocalizedString("Global Font information table", comment: "")
            case .VORG: return NSLocalizedString("Vertical Origin table", comment: "")
            case .STAT: return NSLocalizedString("Style Attributes table", comment: "")
            case .LTSH: return NSLocalizedString("Linear Threshold table", comment: "")
            case .MERG: return NSLocalizedString("Merge table", comment: "")
            case .VDMX: return NSLocalizedString("Vertical Device Metrics table", comment: "")
            case .PCLT: return NSLocalizedString("HP PCL 5 table", comment: "")
            case .acnt: return NSLocalizedString("Accent Attachment table", comment: "")
            case .ankr: return NSLocalizedString("Anchor Point table", comment: "")
            case .avar: return NSLocalizedString("Axis Variations table", comment: "")
            case .bdat: return NSLocalizedString("Bitmap Data table", comment: "")
            case .bhed: return NSLocalizedString("Bitmap Header table", comment: "")
            case .bloc: return NSLocalizedString("Bitmap Location table", comment: "")
            case .bsln: return NSLocalizedString("Baseline table", comment: "")
            case .cmap: return NSLocalizedString("Character-to-Glyph ID Mapping table", comment: "")
            case .cvt_: return NSLocalizedString("Control Value table", comment: "")
            case .fdsc: return NSLocalizedString("Font Descriptors table", comment: "")
            case .feat: return NSLocalizedString("Feature Name table", comment: "")
            case .ltag: return NSLocalizedString("IETF Language Tags table", comment: "")
            case .fpgm: return NSLocalizedString("Font Program table", comment: "")
            case .fond: return NSLocalizedString("FOND and NFNT resource table", comment: "")
            case .cvar: return NSLocalizedString("CVT Variations table", comment: "")
            case .fvar: return NSLocalizedString("Font Variations table", comment: "")
            case .gvar: return NSLocalizedString("Glyph Variations table", comment: "")
            case .fmtx: return NSLocalizedString("Font Metrics table", comment: "")
            case .gasp: return NSLocalizedString("Grid-Fitting and Scan-Conversion Procedure table", comment: "")
            case .glyf: return NSLocalizedString("Glyf (TrueType outline) data", comment: "")
            case .head: return NSLocalizedString("Font Header table", comment: "")
            case .hhea: return NSLocalizedString("Horizontal Header table", comment: "")
            case .hmtx: return NSLocalizedString("Horizontal Metrics table", comment: "")
            case .hdmx: return NSLocalizedString("Horizontal Device Metrics table", comment: "")
            case .hvgl: return NSLocalizedString("Hierarchical Variation font table", comment: "")
            case .hvpm: return NSLocalizedString("Hierarchical Variation font table", comment: "")
            case .just: return NSLocalizedString("Justification table", comment: "")
            case .lcar: return NSLocalizedString("Ligature Caret table", comment: "")
            case .loca: return NSLocalizedString("Glyf Location table", comment: "")
            case .kern: return NSLocalizedString("Kerning table", comment: "")
            case .kerx: return NSLocalizedString("Extended Kerning table", comment: "")
            case .maxp: return NSLocalizedString("Maximum Profile table", comment: "")
            case .meta: return NSLocalizedString("Metadata table", comment: "")
            case .mort: return NSLocalizedString("Glyph Metamorphosis table", comment: "")
            case .morx: return NSLocalizedString("Extended Glyph Metamorphosis table", comment: "")
            case .name: return NSLocalizedString("Naming table", comment: "")
            case .opbd: return NSLocalizedString("Optical Bounds table", comment: "")
            case .post: return NSLocalizedString("PostScript info table", comment: "")
            case .prep: return NSLocalizedString("Control value program", comment: "")
            case .prop: return NSLocalizedString("Glyph Properties table", comment: "")
            case .sbix: return NSLocalizedString("Standard bitmap graphics table", comment: "")
            case .trak: return NSLocalizedString("Tracking table", comment: "")
            case .vhea: return NSLocalizedString("Vertical Header table", comment: "")
            case .vmtx: return NSLocalizedString("Vertical Metrics table", comment: "")
            case .xref: return NSLocalizedString("Cross-Reference table", comment: "")
            case .Zapf: return NSLocalizedString("Glyph Info table", comment: "")
            case .evrs, .TYP1, .CID_, .BLND:
                fallthrough
            default: return NSLocalizedString("\(fourCharString) table", comment: "")
        }
    }

    public var debugDescription: String {
        return fourCharString
    }

    public static func < (lhs: TableTag, rhs: TableTag) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    public static func == (lhs: TableTag, rhs: TableTag) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public static let allCases: [TableTag] = [.BASE, .CFF_, .CFF2, .DSIG, .TYP1, .CID_, .gcid, .BLND, .EBDT, .EBLC, .EBSC, .CBDT, .CBLC, .SVG_, .COLR, .CPAL, .GDEF, .GPOS, .GSUB, .JSTF, .MATH, .OS_2, .VORG, .STAT, .LTSH, .MERG, .VDMX, .PCLT, .acnt, .ankr, .avar, .bdat, .bhed, .bloc, .bsln, .cmap, .cvt_, .fdsc, .evrs, .feat, .ltag, .fpgm, .fond, .cvar, .fvar, .gvar, .fmtx, .gasp, .glyf, .head, .hhea, .hmtx, .hdmx, .hvgl, .hvpm, .just, .lcar, .loca, .kern, .kerx, .maxp, .meta, .mort, .morx, .name, .opbd, .post, .prep, .prop, .sbix, .trak, .vhea, .vmtx, .xref, .Zapf]

}

// MARK: -
@objc public enum PlatformID: UInt16, Comparable, CustomStringConvertible, CustomDebugStringConvertible {
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

    public var debugDescription: String {
        switch self {
            case .unicode:      return "Uni"
            case .mac:          return "Mac"
            case .iso:          return "ISO"
            case .microsoft:    return "MS™"
            case .custom:       return "Cus"
            case .any:          return "Any"
        }
    }
}

// MARK: -
@objc public enum UnicodeEncodingID: UInt16, Comparable, CustomStringConvertible, CustomDebugStringConvertible {
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

    public var debugDescription: String {
        return "\(rawValue)"
    }
}

/// ``MacScriptID`` & ``MacLanguageID`` are in CoreFontTypes.swift

// MARK: -
@objc public enum MicrosoftEncodingID : UInt16, Comparable, CustomStringConvertible, CustomDebugStringConvertible {
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

    public var debugDescription: String {
        return "\(rawValue)"
    }
}

/// Only meaningfully used in `FontTable_name.NameRecord`, not in `cmap` entries
@objc public enum MicrosoftLanguageID: UInt16, Comparable, CustomStringConvertible, CustomDebugStringConvertible {
    case none                       = 0     /// not-applicable (for `cmap`s)
    case arabicSaudiArabia          = 1025  // 0x0401
    case bulgarian                  = 1026  // 0x0402
    case catalan                    = 1027  // 0x0403
    case chineseTaiwan              = 1028  // 0x0404
    case czech                      = 1029  // 0x0405
    case danish                     = 1030  // 0x0406
    case german                     = 1031  // 0x0407
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
            case .none: return NSLocalizedString("--", comment: "")
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

    public var debugDescription: String {
        return "\(rawValue)"
    }
}

// MARK: -
public enum EncodingID: Comparable, CustomStringConvertible, CustomDebugStringConvertible {
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

    public func mac() -> MacScriptID? {
        guard case .mac(let encID) = self else { return nil }
        return encID
    }

    public func microsoft() -> MicrosoftEncodingID? {
        guard case .microsoft(let encID) = self else { return nil }
        return encID
    }

    public func unicode() -> UnicodeEncodingID? {
        guard case .unicode(let encID) = self else { return nil }
        return encID
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

    public static func < (lhs: EncodingID, rhs: EncodingID) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    public static func == (lhs: EncodingID, rhs: EncodingID) -> Bool {
        return lhs.rawValue == rhs.rawValue
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

    public var debugDescription: String {
        switch self {
            case .unicode(let encID):
                return encID.debugDescription
            case .mac(let encID):
                return encID.debugDescription
            case .microsoft(let encID):
                return encID.debugDescription
            case .any:
                return "any"
        }
    }
}


public enum LanguageID: Comparable, CustomStringConvertible, CustomDebugStringConvertible {
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

    /// for `cmap` Subtable formats 12, 13+
    public var extendedRawValue: UInt32 {
        return UInt32(rawValue)
    }

    public func mac() -> MacLanguageID? {
        guard case .mac(let langID) = self else { return nil }
        return langID
    }

    public func microsoft() -> MicrosoftLanguageID? {
        guard case .microsoft(let langID) = self else { return nil }
        return langID
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

    public static func languageIDWith(platformID: PlatformID, extendedLanguageID: UInt32) throws -> LanguageID {
        return try languageIDWith(platformID: platformID, languageID: UInt16(extendedLanguageID))
    }

    /// In 'cmap's, `MacLanguageID` values are 1-based. If a 'cmap' encoding subtable has `languageID` == 0,
    /// that means that that encoding is not language-dependent. Otherwise, subtract 1 from the value
    /// to get the real `languageID`
    public func macStandardized() -> LanguageID {
        guard case .mac(let langID) = self else { return self }
        if langID.rawValue == 0 { return self }
        return .mac(MacLanguageID(rawValue: langID.rawValue - 1)!)
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

    public var debugDescription: String {
        switch self {
            case .unicode:
                return NSLocalizedString("--", comment: "")
            case .mac(let langID):
                return langID.debugDescription
            case .microsoft(let langID):
                return langID.debugDescription
            case .any:
                return NSLocalizedString("Any", comment: "")
        }
    }
}


public extension FontTable_name {

    enum FontNameID: Hashable, CustomStringConvertible, CustomDebugStringConvertible {
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

        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
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

        public var debugDescription: String {
            return "\(self.rawValue)"
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

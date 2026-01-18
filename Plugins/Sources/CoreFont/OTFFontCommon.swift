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
public typealias Tag       = UInt32

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

public struct TableTag: RawRepresentable, Equatable {
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
}

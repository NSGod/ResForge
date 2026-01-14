//
//  FontCommon.swift
//  FontEditor
//
//  Created by Mark Douma on 1/10/2026.
//

import Foundation
import RFSupport

typealias GlyphID   = UInt16
typealias Glyph32ID = UInt32
typealias Tag       = UInt32

struct FFsfntFormat: RawRepresentable, Equatable {
    let rawValue: UInt32

    static let `true`:  FFsfntFormat = .init(rawValue: UInt32(fourCharString: "true"))
    static let OTTO:    FFsfntFormat = .init(rawValue: UInt32(fourCharString: "OTTO"))
    static let typ1:    FFsfntFormat = .init(rawValue: UInt32(fourCharString: "typ1"))
    static let V1_0:    FFsfntFormat = .init(rawValue: 0x00010000)
    static let ttcf:    FFsfntFormat = .init(rawValue: UInt32(fourCharString: "ttcf"))
    static let _kbd:    FFsfntFormat = .init(rawValue: 0xA56B6264) // '•kbd'    .Keyboard
    static let _lst:    FFsfntFormat = .init(rawValue: 0xA56C7374) // '•lst'    .LastResort
    static let vt10:    FFsfntFormat = .init(rawValue: 0x35ECFAA2) // VT100
    static let vt1b:    FFsfntFormat = .init(rawValue: 0x498182F0) // VT100-Bold

}

struct TableTag: RawRepresentable, Equatable {
    let rawValue: Tag

    static let BASE    = Self(rawValue: Tag(fourCharString: "BASE"))    // Baseline data table (opt)
    static let CFF_    = Self(rawValue: Tag(fourCharString: "CFF "))    // Compact Font Format 1.0        OT (req)
    static let CFF2    = Self(rawValue: Tag(fourCharString: "CFF2"))    // Compact Font Format 2.0        OT (req)
    static let DSIG    = Self(rawValue: Tag(fourCharString: "DSIG"))    // digital signature (opt)

    static let TYP1    = Self(rawValue: Tag(fourCharString: "TYP1"))    //
    static let CID_    = Self(rawValue: Tag(fourCharString: "CID "))    //
    static let gcid    = Self(rawValue: Tag(fourCharString: "gcid"))    // glyphIDs to CMap CIDs table    TT (opt)

    static let BLND    = Self(rawValue: Tag(fourCharString: "BLND"))    //

    static let EBDT    = Self(rawValue: Tag(fourCharString: "EBDT"))    // Embedded bitmap data (B&W/grayscale) (bitmap-only TT fonts)
    static let EBLC    = Self(rawValue: Tag(fourCharString: "EBLC"))    // Embedded bitmap location data (bitmap-only TT fonts)
    static let EBSC    = Self(rawValue: Tag(fourCharString: "EBSC"))    // Embedded bitmap scaling data (bitmap-only TT fonts)

    static let CBDT    = Self(rawValue: Tag(fourCharString: "CBDT"))    // Color bitmap data
    static let CBLC    = Self(rawValue: Tag(fourCharString: "CBLC"))    // Color bitmap location data

    static let SVG_    = Self(rawValue: Tag(fourCharString: "SVG "))    // The SVG (Scalable Vector Graphics) table

    static let COLR    = Self(rawValue: Tag(fourCharString: "COLR"))    // Color table
    static let CPAL    = Self(rawValue: Tag(fourCharString: "CPAL"))    // Color palette table

    static let GDEF    = Self(rawValue: Tag(fourCharString: "GDEF"))    // Glyph definition data        OT (opt)
    static let GPOS    = Self(rawValue: Tag(fourCharString: "GPOS"))    // Glyph positioning data        OT & TT (opt)
    static let GSUB    = Self(rawValue: Tag(fourCharString: "GSUB"))    // Glyph substitution data        OT (opt)
    static let JSTF    = Self(rawValue: Tag(fourCharString: "JSTF"))    // Justification data            OT (opt)
    static let MATH    = Self(rawValue: Tag(fourCharString: "MATH"))    // Math layout data                OT (opt)

    static let OS_2    = Self(rawValue: Tag(fourCharString: "OS/2"))    // OS/2 and Windows-specific metrics (req)
    static let VORG    = Self(rawValue: Tag(fourCharString: "VORG"))    // Vertical Origin                OT only (opt)

    static let STAT    = Self(rawValue: Tag(fourCharString: "STAT"))    // Style attr table (for variable fonts?) OT opt

    static let LTSH    = Self(rawValue: Tag(fourCharString: "LTSH"))    // linear threshold table        TT (opt)
    static let MERG    = Self(rawValue: Tag(fourCharString: "MERG"))    // Merge before antialiasing table (opt)

    static let VDMX    = Self(rawValue: Tag(fourCharString: "VDMX"))    // vertical device metrics        TT (opt)
    static let PCLT    = Self(rawValue: Tag(fourCharString: "PCLT"))    // PCL5 HP table (strongly discouraged) TT (opt)

    static let bdat    = Self(rawValue: Tag(fourCharString: "bdat"))    // Bitmap data table
    static let bhed    = Self(rawValue: Tag(fourCharString: "bhed"))    // Bitmap font header (Mac equiv to 'head' for bitmap-only TT fonts)
    static let bloc    = Self(rawValue: Tag(fourCharString: "bloc"))    // Bitmap location table

    static let bsln    = Self(rawValue: Tag(fourCharString: "bsln"))    // baseline table
    static let cmap    = Self(rawValue: Tag(fourCharString: "cmap"))    // Character codes to glyph index mappings    (req)
    static let cvt_    = Self(rawValue: Tag(fourCharString: "cvt "))    // Control Value Table             TT (opt)
    static let fdsc    = Self(rawValue: Tag(fourCharString: "fdsc"))    // font descriptors table        (opt)

    static let evrs    = Self(rawValue: Tag(fourCharString: "evrs"))    // ??

    static let feat    = Self(rawValue: Tag(fourCharString: "feat"))    // feature table                 AAT TT (opt)
    static let ltag    = Self(rawValue: Tag(fourCharString: "ltag"))    // AAT TT (opt) OS X 10.9+ used with 'morx' & 'feat' tables

    static let fpgm    = Self(rawValue: Tag(fourCharString: "fpgm"))    // Font program                 TT (opt)

    static let fond    = Self(rawValue: Tag(fourCharString: "fond"))    // Mac 'FOND' resources            TT (opt)

    static let cvar    = Self(rawValue: Tag(fourCharString: "cvar"))    // 'cvt ' variations table        AAT (opt)
    static let fvar    = Self(rawValue: Tag(fourCharString: "fvar"))    // Font Variations Table         AAT (opt)
    static let gvar    = Self(rawValue: Tag(fourCharString: "gvar"))    // Glyph Variations Table        AAT (opt)

    static let fmtx    = Self(rawValue: Tag(fourCharString: "fmtx"))    // Font Metrics Table            AAT (opt)
    static let gasp    = Self(rawValue: Tag(fourCharString: "gasp"))    // Grid-fitting/Scan-conversion    TT (opt)
    static let glyf    = Self(rawValue: Tag(fourCharString: "glyf"))    // Glyph data                    TT (req) OT (opt)

    static let head    = Self(rawValue: Tag(fourCharString: "head"))    // Font header                    (req)

    static let hhea    = Self(rawValue: Tag(fourCharString: "hhea"))    // Horizontal Header            (req)
    static let hmtx    = Self(rawValue: Tag(fourCharString: "hmtx"))    // Horizontal metrics            (req)

    static let hdmx    = Self(rawValue: Tag(fourCharString: "hdmx"))    // Horizontal device metrics    Mac (opt)

    static let just    = Self(rawValue: Tag(fourCharString: "just"))    // Justification table            AAT (opt)
    static let lcar    = Self(rawValue: Tag(fourCharString: "lcar"))    // Ligature caret table            AAT (opt)

    static let loca    = Self(rawValue: Tag(fourCharString: "loca"))    // Index to location            TT (req)
    static let kern    = Self(rawValue: Tag(fourCharString: "kern"))    // Kerning table                TT (opt)
    static let kerx    = Self(rawValue: Tag(fourCharString: "kerx"))    // Extended Kerning table        AAT (opt)

    static let maxp    = Self(rawValue: Tag(fourCharString: "maxp"))    // Maximum profile                (req)

    static let meta    = Self(rawValue: Tag(fourCharString: "meta"))    // Metadata table (design lang, sup. lang) AAT (opt)
    static let mort    = Self(rawValue: Tag(fourCharString: "mort"))    // Glyph Metamorphosis table (deprecated) AAT (opt)
    static let morx    = Self(rawValue: Tag(fourCharString: "morx"))    // Extended Glyph Metamorphosis AAT

    static let name    = Self(rawValue: Tag(fourCharString: "name"))    // Naming table                    (req)
    static let opbd    = Self(rawValue: Tag(fourCharString: "opbd"))    // Optical bounds table            AAT (opt)

    static let post    = Self(rawValue: Tag(fourCharString: "post"))    // PostScript information        (req)
    static let prep    = Self(rawValue: Tag(fourCharString: "prep"))    // CV Program                    TT (opt)
    static let prop    = Self(rawValue: Tag(fourCharString: "prop"))    // Glyph Properties table

    static let sbix    = Self(rawValue: Tag(fourCharString: "sbix"))    // Standard graphics format bitmap data (full color) (Apple-only?)
    static let trak    = Self(rawValue: Tag(fourCharString: "trak"))    // Tracking table                AAT (opt)

    static let vhea    = Self(rawValue: Tag(fourCharString: "vhea"))    // Vertical header table        TT (opt)
    static let vmtx    = Self(rawValue: Tag(fourCharString: "vmtx"))    // Vertical metrics table        TT (opt)

    static let Zapf    = Self(rawValue: Tag(fourCharString: "Zapf"))    //                                 AAT (opt)

}

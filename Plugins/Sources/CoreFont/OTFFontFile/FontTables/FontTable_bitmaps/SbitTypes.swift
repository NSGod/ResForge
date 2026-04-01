//
//  SbitTypes.swift
//  CoreFont
//
//  Created by Mark Douma on 3/24/2026.
//

/// Some of the descriptions are taken, in part, from Adobe's afdko code at:
/// https://github.com/adobe-type-tools/afdko/blob/develop/c/spot/sfnt_includes/sfnt_bloc.h
/// https://github.com/adobe-type-tools/afdko/blob/develop/c/spot/sfnt_includes/sfnt_sbit.h
/* Copyright 2014 Adobe Systems Incorporated (http://www.adobe.com/). All Rights Reserved.
   This software is licensed as OpenSource, under the Apache License, Version 2.0.
   This license is available at: http://opensource.org/licenses/Apache-2.0. */

import Foundation
import RFSupport

/// These data types can be used by both Apple's bitmap fonts
/// (`bhed`, `bloc`, and `bdat` tables) and by Microsoft's
/// identical-but-differently-named bitmap fonts (`head`,
/// `EBLC`, and `EBDT`), so we put them in a separate namespace of `Sbit`
///
// MARK:  Sbit = "Scaler Bitmaps"
public enum Sbit {

    public enum IndexFormat: UInt16 {
        case unknown                = 0
        case proportional           = 1
        case mono                   = 2
        case proportionalSmall      = 3
        case proportionalSparse     = 4
        case monoSparse             = 5
    }

    public enum GlyphImageFormat: UInt16 {
        case unknown                = 0
        case proportionalSmallByte  = 1     /// small metrics & data, byte-aligned
        case proportionalSmallBit   = 2     /// small metrics & data, bit-aligned
        case proportionalCompressed = 3     /// not used (obsolete)                     `NOT SUPPORTED`
        case monoCompressed         = 4     /// just compressed data; metrics in 'bloc' `NOT SUPPORTED`
        case mono                   = 5     /// bit-aligned data; metrics in 'bloc'
        case proportionalBigByte    = 6     /// big metrics & byte-aligned data
        case proportionalBigBit     = 7     /// big metrics & bit-aligned data
        case componentSmall         = 8     /// small metrics, component data; used in `EBDT`, not `bdat`
        case componentBig           = 9     /// big metrics, component data; used in `EBDT`, not `bdat`

        public var isSupported: Bool {
            return self != .unknown && self != .proportionalCompressed && self != .monoCompressed
        }

        public var hasMonoMetrics: Bool {
            return self == .mono || self == .monoCompressed
        }

        public var hasSmallMetrics: Bool {
            return self == .proportionalSmallBit || self == .proportionalSmallByte || self == .componentSmall
        }

        public var hasBigMetrics: Bool {
            return self == .proportionalBigBit || self == .proportionalBigByte || self == .componentBig
        }

        public var hasComponents: Bool {
            return self == .componentSmall || self == .componentBig
        }

        public var isByteAligned: Bool {
            return self == .proportionalBigByte || self == .proportionalSmallByte
        }

        public var isBitAligned: Bool {
            return self == .proportionalSmallBit || self == .proportionalBigBit ||  self == .mono
        }
    }

    // MARK: -
    public class LineMetrics: Node {
        public var ascender:                Int8 = 0    /// This is the spacing of the line before the baseline
        public var descender:               Int8 = 0    /// This is the spacing of the line after the baseline
        public var widthMax:                UInt8 = 0   /// Maximum pixel width of glyphs in strike. (Not used by AAT)
        public var caretSlopeNumerator:     Int8 = 0    /// Rise of caret slope, typically set to 1 for non-italic fonts
        public var caretSlopeDenominator:   Int8 = 0    /// Run of caret slope, typically set to 0 for non-italic fonts
        public var caretOffset:             Int8 = 0    /// Offset in pixels to move the caret for proper positioning
        public var minOriginSB:             Int8 = 0    /// Minimum of horiBearingX (or vertBearingY for a vertical font)
        public var minAdvanceSB:            Int8 = 0    ///
        public var maxBeforeBL:             Int8 = 0    ///
        public var minAfterBL:              Int8 = 0    ///
        public var padding:                 Int16 = 0

        public override class var nodeLength: UInt32 {
            return UInt32(MemoryLayout<UInt8>.size * 10 + MemoryLayout<Int16>.size) // 12
        }

        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            ascender = try reader.read()
            descender = try reader.read()
            widthMax = try reader.read()
            caretSlopeNumerator = try reader.read()
            caretSlopeDenominator = try reader.read()
            caretOffset = try reader.read()
            minOriginSB = try reader.read()
            minAdvanceSB = try reader.read()
            maxBeforeBL = try reader.read()
            minAfterBL = try reader.read()
            padding = try reader.read()
            try super.init(reader, offset: offset)
        }
    }

    public enum GlyphMetrics {
        case small(SmallGlyphMetrics)
        case big(BigGlyphMetrics)

        public init(_ metric: Node) {
            if let metric = metric as? SmallGlyphMetrics {
                self = .small(metric)
            } else {
                self = .big(metric as! BigGlyphMetrics)
            }
        }

        public var height: UInt8 {
            if let smallMetrics { return smallMetrics.height } else { return bigMetrics!.height }
        }

        public var width: UInt8 {
            if let smallMetrics { return smallMetrics.width } else { return bigMetrics!.width }
        }

        public var smallMetrics: SmallGlyphMetrics? {
            if case let .small(smallGlyphMetrics) = self {
                return smallGlyphMetrics
            }
            return nil
        }

        public var bigMetrics: BigGlyphMetrics? {
            if case let .big(bigGlyphMetrics) = self {
                return bigGlyphMetrics
            }
            return nil
        }
    }

    // MARK: -
    public class BigGlyphMetrics: Node {
        public var height:          UInt8   // # of rows of glyph image data
        public var width:           UInt8   // # of columns of glyph image data
        public var horiBearingX:    Int8    // dist. (px) from horiz. origin to left edge of bitmap
        public var horiBearingY:    Int8    // dist. (px) from horiz. origin to top edge of bitmap
        public var horiAdvance:     UInt8   // horizontal advance width in pixels
        public var vertBearingX:    Int8    // dist. (px) from vert. origin to left edge of bitmap
        public var vertBearingY:    Int8    // dist. (px) from vert. origin to top edge of bitmap
        public var vertAdvance:     UInt8   // vertical advance width (height) in pixels

        public override class var nodeLength: UInt32 {
            return UInt32(MemoryLayout<UInt8>.size * 8)     // 8
        }

        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            height = try reader.read()
            width = try reader.read()
            horiBearingX = try reader.read()
            horiBearingY = try reader.read()
            horiAdvance = try reader.read()
            vertBearingX = try reader.read()
            vertBearingY = try reader.read()
            vertAdvance = try reader.read()
            try super.init(reader, offset: offset)
        }
    }

    // MARK: -
    // must consult BitmapSizeTable.flags to see whether these are horizontal or vertical
    public class SmallGlyphMetrics: Node {
        public var height:      UInt8   // # of rows of glyph image data
        public var width:       UInt8   // # of columns of glyph image data
        public var bearingX:    Int8    /// see `horiBearingX` or `vertBearingX` depending on `isHorizontal`
        public var bearingY:    Int8    /// see `horiBearingY` or `vertBearingY` depending on `isHorizontal`
        public var advance:     UInt8   /// horizontal or vertical advance width/height in pixels

        public var isHorizontal: Bool

        public override class var nodeLength: UInt32 {
            return UInt32(MemoryLayout<UInt8>.size * 5)     // 5
        }

        public required init(_ reader: BinaryDataReader, isHorizontal: Bool) throws {
            self.isHorizontal = isHorizontal
            height = try reader.read()
            width = try reader.read()
            bearingX = try reader.read()
            bearingY = try reader.read()
            advance = try reader.read()
            try super.init(reader)
        }

        @available(*, unavailable, message: "use init(_:isHorizontal:)")
        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            fatalError("use init(_:isHorizontal:)")
        }
    }
}

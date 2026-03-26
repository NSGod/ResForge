//
//  Sbit.swift
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

// MARK: -
public enum Sbit {

    @objc public enum IndexFormat: UInt16 {
        case unknown                = 0
        case proportional           = 1
        case mono                   = 2
        case proportionalSmall      = 3
        case proportionalSparse     = 4
        case monoSparse             = 5
    }

    @objc public enum DataFormat: UInt16 {
        case unknown                = 0
        case proportionalSmallByte  = 1     // small metrics & data, byte-aligned
        case proportionalSmallBit   = 2     // small metrics & data, bit-aligned
        case proportionalCompressed = 3     // not used
        case monoCompressed         = 4     // just compressed data; metrics in 'bloc'
        case mono                   = 5     // bit-aligned data; metrics in 'bloc'
        case proportionalBigByte    = 6     // big metrics & byte-aligned data
        case proportionalBigBit     = 7     // big metrics & bit-aligned data
        case componentSmall         = 8     // small metrics, component data
        case componentBig           = 9     // big metrics, component data
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

    // MARK: -
    public class BigGlyphMetrics: Node {
        public var height:          UInt8 = 0
        public var width:           UInt8 = 0
        public var horiBearingX:    Int8 = 0
        public var horiBearingY:    Int8 = 0
        public var horiAdvance:     UInt8 = 0
        public var vertBearingX:    Int8 = 0
        public var vertBearingY:    Int8 = 0
        public var vertAdvance:     UInt8 = 0

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
    public class SmallGlyphMetrics: Node {
        public var height:      UInt8
        public var width:       UInt8
        public var bearingX:    Int8
        public var bearingY:    Int8
        public var advance:     UInt8

        public override class var nodeLength: UInt32 {
            return UInt32(MemoryLayout<UInt8>.size * 5)     // 5
        }

        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            height = try reader.read()
            width = try reader.read()
            bearingX = try reader.read()
            bearingY = try reader.read()
            advance = try reader.read()
            try super.init(reader, offset: offset)
        }
    }
}

//
//  Sbit.IndexSubtable.Format.swift
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

extension Sbit.IndexSubtable {

    /// in `bloc`/`EBLC` table
    public class Format: Node {
        // MARK: AUX:
        public var glyphIDsToRanges: [GlyphID: Range<UInt32>] = [:]
        public var monospacedMetrics:           Sbit.BigGlyphMetrics?   /// present in `Format2` and `Format5`

        public required init(_ reader: BinaryDataReader, glyphIDRange: ClosedRange<GlyphID>) throws {
            try super.init(reader)
        }

        @available(*, unavailable, message: "use init(_:glyphIDRange:)")
        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            fatalError("use init(_:glyphIDRange:)")
        }

        public static func `class`(for format: Sbit.IndexFormat) -> Format.Type? {
            switch format {
                case .unknown:              return nil
                case .proportional:         return Format1.self
                case .mono:                 return Format2.self
                case .proportionalSmall:    return Format3.self
                case .proportionalSparse:   return Format4.self
                case .monoSparse:           return Format5.self
            }
        }
    }

    // MARK: -
    /// `Format 1` has variable-length images of the same format for uncompressed, *proportionally-spaced* glyphs.
    public final class Format1 : Format {
        public var offsets:             [UInt32] = []
        private var _numOffsets:        Int = 0

        public override var nodeLength: UInt32 {
            return UInt32(MemoryLayout<UInt32>.size * offsets.count)
        }

        public required init(_ reader: BinaryDataReader, glyphIDRange: ClosedRange<GlyphID>) throws {
            try super.init(reader, glyphIDRange: glyphIDRange)
            _numOffsets = Int(glyphIDRange.upperBound - glyphIDRange.lowerBound) + 2
            offsets = try (0..<_numOffsets).map { _ in try reader.read() }
            var i = 0
            while i <= (glyphIDRange.upperBound - glyphIDRange.lowerBound) {
                glyphIDsToRanges[glyphIDRange.lowerBound + GlyphID(i)] = offsets[i]..<(offsets[i + 1])
                i += 1
            }
        }
    }

    // MARK: -
    /// `Format 2` has fixed-length images of the same format for *mono-spaced* glyphs.
    public final class Format2 : Format {
        public var imageSize:           UInt32 = 0              // images may be compressed, bit-aligned, or byte-aligned
        public var metrics:             Sbit.BigGlyphMetrics!   // all glyphs share same metrics

        public override var nodeLength: UInt32 {
            return Self.nodeLength
        }

        public class override var nodeLength: UInt32 {
            return 4 + Sbit.BigGlyphMetrics.nodeLength
        }

        public required init(_ reader: BinaryDataReader, glyphIDRange: ClosedRange<GlyphID>) throws {
            imageSize = try reader.read()
            metrics = try Sbit.BigGlyphMetrics(reader)
            try super.init(reader, glyphIDRange: glyphIDRange)
            monospacedMetrics = metrics
            var currentOffset: UInt32 = 0
            for glyphID in glyphIDRange {
                glyphIDsToRanges[glyphID] = currentOffset..<(currentOffset + imageSize)
                currentOffset += imageSize
            }
        }
    }

    // MARK: -
    /// `Format 3` is similar to 1, but with 16-bit offsets, for compressed,
    ///  *proportionally-spaced* glyphs. Must be padded at end to a long-word boundry.
    public final class Format3 : Format {
        public var offsets:             [UInt16] = []
        private var _numOffsets:        Int = 0

        public required init(_ reader: BinaryDataReader, glyphIDRange: ClosedRange<GlyphID>) throws {
            try super.init(reader, glyphIDRange: glyphIDRange)
            _numOffsets = Int(glyphIDRange.upperBound - glyphIDRange.lowerBound) + 2
            offsets = try (0..<_numOffsets).map { _ in try reader.read() }
            if _numOffsets & 1 != 0 {
                /// consume padding if applicable
                _ = try reader.read() as UInt16
            }
            var i = 0
            while i <= (glyphIDRange.upperBound - glyphIDRange.lowerBound) {
                glyphIDsToRanges[glyphIDRange.lowerBound + GlyphID(i)] = UInt32(offsets[i])..<UInt32(offsets[i + 1])
                i += 1
            }
        }

        // FIXME: need padded length?
        public override var nodeLength: UInt32 {
            return UInt32(MemoryLayout<UInt32>.size * offsets.count)
        }
    }


    // MARK: -
    public final class GlyphIDOffsetPair: Node {
        public var glyphID:             GlyphID
        public var offset:              UInt16        // location in 'bdat'

        public override class var nodeLength: UInt32 {
            return 2 + 2                                    // 4
        }

        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            assert(offset == nil)
            glyphID = try reader.read()
            self.offset = try reader.read()
            try super.init(reader, offset: offset)
        }
    }

    // MARK: -
    /// `Format 4` is for sparsely-embedded glyph data for *proportional* metrics
    public final class Format4 : Format {
        public var numGlyphs:          UInt32 = 0
        public var glyphs:             [GlyphIDOffsetPair] = []    // [numGlyphs + 1]

        public override var nodeLength: UInt32 {
            return 4 + UInt32(glyphs.count) * GlyphIDOffsetPair.nodeLength
        }

        public required init(_ reader: BinaryDataReader, glyphIDRange: ClosedRange<GlyphID>) throws {
            try super.init(reader, glyphIDRange: glyphIDRange)
            numGlyphs = try reader.read()
            glyphs = try (0...numGlyphs).map { _ in try GlyphIDOffsetPair(reader) }
            var currentOffset: UInt32 = 0
            for glyph in glyphs {
                glyphIDsToRanges[glyph.glyphID] = currentOffset..<UInt32(glyph.offset)
                currentOffset += UInt32(glyphIDsToRanges[glyph.glyphID]!.count)
            }
        }
    }

    // MARK: -
    /// `Format 5` is for sparsely-embedded glyph data of fixed-size, *mono-spaced* metrics
    public final class Format5 : Format {
        public var imageSize:           UInt32 = 0
        public var metrics:             Sbit.BigGlyphMetrics!
        public var numGlyphs:           UInt32 = 0
        public var glyphs:              [GlyphIDOffsetPair] = []    // [numGlyphs]

        public override var nodeLength: UInt32 {
            return 4 + 4 + Sbit.BigGlyphMetrics.nodeLength + UInt32(glyphs.count) * GlyphIDOffsetPair.nodeLength
        }

        public required init(_ reader: BinaryDataReader, glyphIDRange: ClosedRange<GlyphID>) throws {
            try super.init(reader, glyphIDRange: glyphIDRange)
            imageSize = try reader.read()
            metrics = try Sbit.BigGlyphMetrics(reader)
            monospacedMetrics = metrics
            numGlyphs = try reader.read()
            glyphs = try (0..<numGlyphs).map { _ in try GlyphIDOffsetPair(reader) }
            var currentOffset: UInt32 = 0
            for glyph in glyphs {
                glyphIDsToRanges[glyph.glyphID] = currentOffset..<UInt32(glyph.offset)
                currentOffset += UInt32(glyphIDsToRanges[glyph.glyphID]!.count)
            }
        }
    }
}

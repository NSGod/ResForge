//
//  IndexSubtable.Format.swift
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

extension FontTable_bloc.IndexSubtable {

    public class Format: Node {

        // MARK: AUX:
        public var glyphIDsToRanges: [GlyphID: Range<UInt32>] = [:]

        public var monospacedMetrics:           Sbit.BigGlyphMetrics?

        public required init(_ reader: BinaryDataReader, indexSubtableArray: FontTable_bloc.IndexSubtableArray) throws {
            try super.init(reader)
        }

        @available(*, unavailable, message: "use init that takes indexSubtableArray")
        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            fatalError("use init that takes indexSubtableArray")
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

        public required init(_ reader: BinaryDataReader, indexSubtableArray: FontTable_bloc.IndexSubtableArray) throws {
            try super.init(reader, indexSubtableArray: indexSubtableArray)
            _numOffsets = Int(indexSubtableArray.lastGlyphIndex - indexSubtableArray.firstGlyphIndex) + 2
            offsets = try (0..<_numOffsets).map { _ in try reader.read() }
            var i = 0
            while i <= (indexSubtableArray.lastGlyphIndex - indexSubtableArray.firstGlyphIndex) {
                glyphIDsToRanges[indexSubtableArray.firstGlyphIndex + GlyphID(i)] = offsets[i]..<(offsets[i + 1])
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

        public required init(_ reader: BinaryDataReader, indexSubtableArray: FontTable_bloc.IndexSubtableArray) throws {
            try super.init(reader, indexSubtableArray: indexSubtableArray)
            imageSize = try reader.read()
            metrics = try Sbit.BigGlyphMetrics(reader)
            monospacedMetrics = metrics
            var currentOffset: UInt32 = 0
            for glyphID in indexSubtableArray.firstGlyphIndex..<indexSubtableArray.lastGlyphIndex + 1 {
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

        public required init(_ reader: BinaryDataReader, indexSubtableArray: FontTable_bloc.IndexSubtableArray) throws {
            try super.init(reader, indexSubtableArray: indexSubtableArray)
            _numOffsets = Int(indexSubtableArray.lastGlyphIndex - indexSubtableArray.firstGlyphIndex) + 2
            offsets = try (0..<_numOffsets).map { _ in try reader.read() }
            if _numOffsets & 1 != 0 {
                /// consume padding if applicable
                _ = try reader.read() as UInt16
            }
            var i = 0
            while i <= (indexSubtableArray.lastGlyphIndex - indexSubtableArray.firstGlyphIndex) {
                glyphIDsToRanges[indexSubtableArray.firstGlyphIndex + GlyphID(i)] = UInt32(offsets[i])..<UInt32(offsets[i + 1])
                i += 1
            }
        }

        // FIXME: need padded length?
        public override var nodeLength: UInt32 {
            return UInt32(MemoryLayout<UInt32>.size * offsets.count)
        }
    }


    // MARK: -
    public final class CodeOffsetPair: Node {
        public var glyphCode:         GlyphID = 0
        public var offset:            UInt16 = 0    // location in 'bdat'

        public override class var nodeLength: UInt32 {
            return 2 + 2                                    // 4
        }

        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            assert(offset == nil)
            glyphCode = try reader.read()
            self.offset = try reader.read()
            try super.init(reader, offset: offset)
        }
    }

    // MARK: -
    /// `Format 4` is for sparsely-embedded glyph data for *proportional* metrics
    public final class Format4 : Format {
        public var numGlyphs:          UInt32 = 0
        public var glyphs:             [CodeOffsetPair] = []

        public override var nodeLength: UInt32 {
            return 4 + UInt32(glyphs.count) * CodeOffsetPair.nodeLength
        }

        public required init(_ reader: BinaryDataReader, indexSubtableArray: FontTable_bloc.IndexSubtableArray) throws {
            try super.init(reader, indexSubtableArray: indexSubtableArray)
            numGlyphs = try reader.read()
            glyphs = try (0..<numGlyphs).map { _ in try CodeOffsetPair(reader) }
            var currentOffset: UInt32 = 0
            for glyph in glyphs {
                glyphIDsToRanges[glyph.glyphCode] = currentOffset..<UInt32(glyph.offset)
                currentOffset += UInt32(glyphIDsToRanges[glyph.glyphCode]!.count)
            }

        }
    }

    // MARK: -
    /// `Format 5` is for sparsely-embedded glyph data of fixed-size, *mono-spaced* metrics
    public final class Format5 : Format {
        public var imageSize:           UInt32 = 0
        public var metrics:             Sbit.BigGlyphMetrics!
        public var numGlyphs:           UInt32 = 0
        public var glyphs:              [CodeOffsetPair] = []    // [numGlyphs]

        public override var nodeLength: UInt32 {
            return 8 + Sbit.BigGlyphMetrics.nodeLength + UInt32(glyphs.count) * CodeOffsetPair.nodeLength
        }

        public required init(_ reader: BinaryDataReader, indexSubtableArray: FontTable_bloc.IndexSubtableArray) throws {
            try super.init(reader, indexSubtableArray: indexSubtableArray)
            imageSize = try reader.read()
            metrics = try Sbit.BigGlyphMetrics(reader)
            monospacedMetrics = metrics
            numGlyphs = try reader.read()
            glyphs = try (0..<numGlyphs).map { _ in try CodeOffsetPair(reader) }
        }
    }
}

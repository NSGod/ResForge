//
//  Sbit.BitmapGlyphFormat.swift
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

extension Sbit {

    public class BitmapGlyphFormat: Node {
        public var glyphs:                  [BitmapGlyph] = []

        public required init(_ reader: BinaryDataReader, sizeTable: FontTable_bloc.BitmapSizeTable) throws {
            let offset = sizeTable.indexSubtableArray.indexSubtable.imageDataOffset
            for (glyphID, range) in sizeTable.indexSubtableArray.indexSubtable.format.glyphIDsToRanges {
                let glyph = try BitmapGlyph(reader, offset: offset, range: range, glyphID: glyphID)
                glyphs.append(glyph)
            }
            glyphs.sort(by: <)
            try super.init(reader)
        }

        @available(*, unavailable, message: "use init that takes a sizeTable")
        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            fatalError("use init that takes a sizeTable")
        }

        public static func `class`(for format: Sbit.GlyphDataFormat) -> BitmapGlyphFormat.Type? {
            switch format {
                case .unknown:                  return nil
                case .proportionalSmallByte:    return BitmapGlyphFormat1.self
                case .proportionalSmallBit:     return BitmapGlyphFormat2.self
                case .proportionalCompressed:   return nil
                case .monoCompressed:           return nil
                case .mono:                     return BitmapGlyphFormat5.self
                case .proportionalBigByte:      return BitmapGlyphFormat6.self
                case .proportionalBigBit:       return BitmapGlyphFormat7.self
                case .componentSmall:           return BitmapGlyphFormat8.self
                case .componentBig:             return BitmapGlyphFormat9.self
            }
        }
    }

    // MARK: - 1
    public final class BitmapGlyphFormat1: BitmapGlyphFormat {
        public var smallMetrics:        Sbit.SmallGlyphMetrics

        public required init(_ reader: BinaryDataReader, sizeTable: FontTable_bloc.BitmapSizeTable) throws {
            reader.pushSavedPosition()
            defer { reader.popPosition() }
            try reader.setPosition(sizeTable.indexSubtableArray.indexSubtable.imageDataOffset)
            smallMetrics = try Sbit.SmallGlyphMetrics(reader)
            try super.init(reader, sizeTable: sizeTable)
            glyphs.forEach { $0.metrics = GlyphMetrics(smallMetrics) }
        }
    }

    // MARK: - 2
    public final class BitmapGlyphFormat2: BitmapGlyphFormat {
        public var smallMetrics:        Sbit.SmallGlyphMetrics!

        public required init(_ reader: BinaryDataReader, sizeTable: FontTable_bloc.BitmapSizeTable) throws {
            reader.pushSavedPosition()
            defer { reader.popPosition() }
            try reader.setPosition(sizeTable.indexSubtableArray.indexSubtable.imageDataOffset)
            smallMetrics = try Sbit.SmallGlyphMetrics(reader)
            try super.init(reader, sizeTable: sizeTable)
            glyphs.forEach { $0.metrics = GlyphMetrics(smallMetrics) }
        }
    }

    /// `Format3` is obsolete
    /// `Format4` isn't supported

    // MARK: - 5
    public final class BitmapGlyphFormat5: BitmapGlyphFormat {
        /// mono metrics are in `bloc` portion
        // public var imageData:           Data!                   // bit-aligned, padded

        public required init(_ reader: BinaryDataReader, sizeTable: FontTable_bloc.BitmapSizeTable) throws {
            reader.pushSavedPosition()
            defer { reader.popPosition() }
            try reader.setPosition(sizeTable.indexSubtableArray.indexSubtable.imageDataOffset)
            try super.init(reader, sizeTable: sizeTable)
            // FIXME: !! figure out metrics
        }
    }

    // MARK: - 6
    /// `Format6`: same as `Format1` but uses big metrics
    public final class BitmapGlyphFormat6: BitmapGlyphFormat {
        public var bigMetrics:          Sbit.BigGlyphMetrics
        // public var imageData:           Data!                   // byte-aligned

        public required init(_ reader: BinaryDataReader, sizeTable: FontTable_bloc.BitmapSizeTable) throws {
            reader.pushSavedPosition()
            defer { reader.popPosition() }
            try reader.setPosition(sizeTable.indexSubtableArray.indexSubtable.imageDataOffset)
            bigMetrics = try Sbit.BigGlyphMetrics(reader)
            try super.init(reader, sizeTable: sizeTable)
            glyphs.forEach { $0.metrics = GlyphMetrics(bigMetrics) }
        }
    }

    // MARK: -
    /// `Format7`: same as `Format2` but uses big metrics
    public final class BitmapGlyphFormat7: BitmapGlyphFormat {
        public var bigMetrics:          Sbit.BigGlyphMetrics
        // public var imageData:           Data!                   // bit-aligned

        public required init(_ reader: BinaryDataReader, sizeTable: FontTable_bloc.BitmapSizeTable) throws {
            reader.pushSavedPosition()
            defer { reader.popPosition() }
            try reader.setPosition(sizeTable.indexSubtableArray.indexSubtable.imageDataOffset)
            bigMetrics = try Sbit.BigGlyphMetrics(reader)
            try super.init(reader, sizeTable: sizeTable)
        }
    }

    /// these later 2 formats generally only found in `EBDT` tables, not `bdat`s
    // MARK: -
    public class Component: Node {
        public var glyphID:         GlyphID
        public var xOffset:         Int8
        public var yOffset:         Int8

        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            glyphID = try reader.read()
            xOffset = try reader.read()
            yOffset = try reader.read()
            try super.init(reader)
        }
    }

    // MARK: -
    public final class BitmapGlyphFormat8: BitmapGlyphFormat {
        public var smallMetrics:        Sbit.SmallGlyphMetrics
        public var pad:                 UInt8
        public var numComponents:       UInt16
        public var components:          [Component]

        public required init(_ reader: BinaryDataReader, sizeTable: FontTable_bloc.BitmapSizeTable) throws {
            reader.pushSavedPosition()
            defer { reader.popPosition() }
            try reader.setPosition(sizeTable.indexSubtableArray.indexSubtable.imageDataOffset)
            smallMetrics = try Sbit.SmallGlyphMetrics(reader)
            pad = try reader.read()
            numComponents = try reader.read()
            components = try (0..<numComponents).map { _ in try Component(reader) }
            try super.init(reader, sizeTable: sizeTable)
            glyphs.forEach { $0.metrics = GlyphMetrics(smallMetrics) }
        }
    }

    // MARK: -
    public final class BitmapGlyphFormat9: BitmapGlyphFormat {
        public var bigMetrics:          Sbit.BigGlyphMetrics
        public var numComponents:       UInt16
        public var components:          [Component]

        public required init(_ reader: BinaryDataReader, sizeTable: FontTable_bloc.BitmapSizeTable) throws {
            reader.pushSavedPosition()
            defer { reader.popPosition() }
            try reader.setPosition(sizeTable.indexSubtableArray.indexSubtable.imageDataOffset)
            bigMetrics = try Sbit.BigGlyphMetrics(reader)
            numComponents = try reader.read()
            components = try (0..<numComponents).map { _ in try Component(reader) }
            try super.init(reader, sizeTable: sizeTable)
            glyphs.forEach { $0.metrics = GlyphMetrics(bigMetrics) }
        }
    }
}

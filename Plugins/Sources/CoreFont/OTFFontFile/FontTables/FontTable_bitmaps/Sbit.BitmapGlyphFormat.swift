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

//    /// these later 2 formats generally only found in `EBDT` tables, not `bdat`s
//    // MARK: -
////    public class Component: Node {
////        public var glyphID:         GlyphID
////        public var xOffset:         Int8
////        public var yOffset:         Int8
////
////        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
////            glyphID = try reader.read()
////            xOffset = try reader.read()
////            yOffset = try reader.read()
////            try super.init(reader)
////        }
////    }
//
//    // MARK: -
//    public final class BitmapGlyphFormat8: BitmapGlyphFormat {
//        public var smallMetrics:        SmallGlyphMetrics
//        public var pad:                 UInt8
//        public var numComponents:       UInt16
//        public var components:          [Component]
//
//        public required init(_ reader: BinaryDataReader, sizeTable: FontTable_bloc.BitmapSizeTable) throws {
//            reader.pushSavedPosition()
//            defer { reader.popPosition() }
//            try reader.setPosition(sizeTable.indexSubtableArray.indexSubtable.imageDataOffset)
//            smallMetrics = try SmallGlyphMetrics(reader, isHorizontal: sizeTable.flags.contains(.horizontal))
//            pad = try reader.read()
//            numComponents = try reader.read()
//            components = try (0..<numComponents).map { _ in try Component(reader) }
//            try super.init(reader, sizeTable: sizeTable)
//            glyphs.forEach { $0.metrics = GlyphMetrics(smallMetrics) }
//        }
//    }
//
//    // MARK: -
//    public final class BitmapGlyphFormat9: BitmapGlyphFormat {
//        public var bigMetrics:          BigGlyphMetrics
//        public var numComponents:       UInt16
//        public var components:          [Component]
//
//        public required init(_ reader: BinaryDataReader, sizeTable: FontTable_bloc.BitmapSizeTable) throws {
//            reader.pushSavedPosition()
//            defer { reader.popPosition() }
//            try reader.setPosition(sizeTable.indexSubtableArray.indexSubtable.imageDataOffset)
//            bigMetrics = try BigGlyphMetrics(reader)
//            numComponents = try reader.read()
//            components = try (0..<numComponents).map { _ in try Component(reader) }
//            try super.init(reader, sizeTable: sizeTable)
//            glyphs.forEach { $0.metrics = GlyphMetrics(bigMetrics) }
//        }
//    }

//
//  GlyphBitmapFormat.swift
//  Plugins
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

extension FontTable_bdat {

    public class GlyphBitmapFormat: Node {
        public required init(_ reader: BinaryDataReader?, offset: Int? = nil) throws {

        }
    }

    public final class GlyphBitmapFormat1: GlyphBitmapFormat {
        public var smallMetrics:        Sbit.SmallGlyphMetrics!
        public var imageData:           Data!

        public required init(_ reader: BinaryDataReader?, offset: Int? = nil) throws {
            try super.init(reader, offset: offset)
            smallMetrics = try Sbit.SmallGlyphMetrics(reader)

        }
    }

    public final class GlyphBitmapFormat2: GlyphBitmapFormat {
        public var smallMetrics:        Sbit.SmallGlyphMetrics!
        public var imageData:           Data!
        
        public required init(_ reader: BinaryDataReader?, offset: Int? = nil) throws {
            try super.init(reader, offset: offset)
            smallMetrics = try Sbit.SmallGlyphMetrics(reader)

        }
    }

    /// `Format4` isn't supported

    public final class GlyphBitmapFormat5: GlyphBitmapFormat {
        /// mono metrics are in 'bloc' portion
        public var imageData:           Data!                   // bit-aligned, padded

        public required init(_ reader: BinaryDataReader?, offset: Int? = nil) throws {
            try super.init(reader, offset: offset)

        }
    }

    public final class GlyphBitmapFormat6: GlyphBitmapFormat {
        public var bigMetrics:          Sbit.BigGlyphMetrics!
        public var imageData:           Data!                   // byte-aligned

        public required init(_ reader: BinaryDataReader?, offset: Int? = nil) throws {
            try super.init(reader, offset: offset)
            bigMetrics = try Sbit.BigGlyphMetrics(reader)

        }
    }

    public final class GlyphBitmapFormat7: GlyphBitmapFormat {
        public var bigMetrics:          Sbit.BigGlyphMetrics!
        public var imageData:           Data!                   // bit-aligned

        public required init(_ reader: BinaryDataReader?, offset: Int? = nil) throws {
            try super.init(reader, offset: offset)

            bigMetrics = try Sbit.BigGlyphMetrics(reader)

        }
    }
}

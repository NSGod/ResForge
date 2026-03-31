//
//  Sbit.IndexSubtable.swift
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

    /// in `bloc` table
    public final class IndexSubtable: Node {
        public var indexFormat:         IndexFormat
        public var imageFormat:         GlyphImageFormat
        public var imageDataOffset:     UInt32                  /// Offset to the base of the image data (`bdat`) for this index subtable
        public var format:              Format!

        public init(_ reader: BinaryDataReader, offset: Int, indexSubtableArray: IndexSubtableArray) throws {
            reader.pushSavedPosition()
            defer { reader.popPosition() }
            try reader.setPosition(offset)
            indexFormat = try reader.read()
            imageFormat = try reader.read()
            imageDataOffset = try reader.read()
            if let formatClass = Format.class(for: indexFormat) {
                format = try formatClass.init(reader, indexSubtableArray: indexSubtableArray)
            }
            try super.init(reader, offset: offset)
        }

        @available(*, unavailable, message: "use init that takes indexSubtableArray")
        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            fatalError("use init that takes indexSubtableArray")
        }
    }
}

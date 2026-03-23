//
//  IndexSubtable.swift
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

extension FontTable_bloc {

    // MARK: -
    public final class IndexSubtableArray: Node {
        public var firstGlyphIndex:                 GlyphID = 0
        public var lastGlyphIndex:                  GlyphID = 0
        public var additionalOffsetToIndexSubtable: UInt32 = 0
        public var indexSubtable:                   IndexSubtable!

        public override class var nodeLength: UInt32 { return 4 + 4 } // 8

        public required init(_ reader: BinaryDataReader? = nil, offset: Int? = nil) throws {
            assert(reader != nil && offset != nil)
            try super.init(reader, offset: offset)
            if let reader, let offset {
                reader.pushSavedPosition()
                defer { reader.popPosition() }
                try reader.setPosition(offset)
                firstGlyphIndex = try reader.read()
                lastGlyphIndex = try reader.read()
                additionalOffsetToIndexSubtable = try reader.read()
                indexSubtable = try IndexSubtable(reader, offset: offset + Int(additionalOffsetToIndexSubtable), indexSubtableArray: self)
            }
        }
    }

    // MARK: -
    public final class IndexSubtable: Node {
        public var indexFormat:         Sbit.IndexFormat = .unknown
        public var imageFormat:         Sbit.DataFormat = .unknown
        public var imageDataOffset:     UInt32 = 0                      /// Offset to the base of the image data (`bdat`) for this index subtable
        public var format:              Format!

        public init(_ reader: BinaryDataReader? = nil, offset: Int? = nil, indexSubtableArray: IndexSubtableArray) throws {
            assert(reader != nil && offset != nil)
            if let reader, let offset {
                reader.pushSavedPosition()
                defer { reader.popPosition() }
                try reader.setPosition(offset)
                indexFormat = try reader.read()
                imageFormat = try reader.read()
                imageDataOffset = try reader.read()
                if let formatClass = Format.class(for: indexFormat) {
                    format = try formatClass.init(reader, indexSubtableArray: indexSubtableArray)
                }
            }
        }
        
        @available(*, unavailable, message: "use init that takes indexSubtableArray")
        public required init(_ reader: BinaryDataReader? = nil, offset: Int? = nil) throws {
            fatalError("use init that takes indexSubtableArray")
        }
    }
}

//
//  Sbit.IndexSubtableArray.swift
//  CoreFont
//
//  Created by Mark Douma on 3/31/2026.
//

import Foundation
import RFSupport

extension Sbit {

    /// in `bloc`/`EBLC` table
    public final class IndexSubtableArray: Node {
        public var firstGlyphIndex:                 GlyphID = 0     /// first glyphID in this range
        public var lastGlyphIndex:                  GlyphID = 0     /// last glyphID in this range (inclusive)
        public var additionalOffsetToIndexSubtable: UInt32 = 0
        public var indexSubtable:                   IndexSubtable!

        public override class var nodeLength: UInt32 { return 2 + 2 + 4 } // 8

        public required init(_ reader: BinaryDataReader, offset: Int) throws {
            firstGlyphIndex = try reader.read()
            lastGlyphIndex = try reader.read()
            additionalOffsetToIndexSubtable = try reader.read()
            indexSubtable = try IndexSubtable(reader, offset: offset + Int(additionalOffsetToIndexSubtable), glyphIDRange: firstGlyphIndex...lastGlyphIndex)
            try super.init(reader, offset: offset)
        }

        @available(*, unavailable, message: "use init that takes non-optional offset")
        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            fatalError("use init that takes non-optional offset")
        }
    }
}

//
//  Sbit.IndexSubtableArray.swift
//  CoreFont
//
//  Created by Mark Douma on 3/31/2026.
//

import Foundation
import RFSupport

extension Sbit {

    /// in `bloc` table
    public final class IndexSubtableArray: Node {
        public var firstGlyphIndex:                 GlyphID = 0
        public var lastGlyphIndex:                  GlyphID = 0
        public var additionalOffsetToIndexSubtable: UInt32 = 0
        public var indexSubtable:                   IndexSubtable!

        public override class var nodeLength: UInt32 { return 4 + 4 } // 8

        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            assert(offset != nil)
            try super.init(reader, offset: offset)
            if let offset {
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
}

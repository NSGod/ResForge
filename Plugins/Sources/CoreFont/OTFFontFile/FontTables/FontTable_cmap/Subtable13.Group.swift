//
//  Subtable13.Group.swift
//  CoreFont
//
//  Created by Mark Douma on 3/5/2026.
//

import Foundation
import RFSupport

extension FontTable_cmap.Subtable13 {

    public final class Group: FontTableNode {
        public var startCharCode:       CharCode32 = 0
        public var endCharCode:         CharCode32 = 0
        public var glyphID:             GlyphID32 = 0

        public override class var nodeLength: UInt32 { 12 }

        public required override init(_ reader: BinaryDataReader?, offset: Int? = nil, table: FontTable) throws {
            assert(offset == nil)
            try super.init(reader, offset: offset, table: table)
            if let reader {
                startCharCode = try reader.read()
                endCharCode = try reader.read()
                glyphID = try reader.read()
            }
        }

        public override func write(to handle: DataHandle, offset: Int? = nil) throws {
            assert(offset == nil)
            handle.write(startCharCode)
            handle.write(endCharCode)
            handle.write(glyphID)
        }
    }
}

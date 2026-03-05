//
//  Subtable12.Group.swift
//  CoreFont
//
//  Created by Mark Douma on 2/25/2026.
//

import Foundation
import RFSupport

extension FontTable_cmap.Subtable12 {

    public final class Group: FontTableNode {
        public var startCharCode:       CharCode32 = 0
        public var endCharCode:         CharCode32 = 0
        public var startGlyphID:        GlyphID32 = 0

        public override class var nodeLength: UInt32 { 12 }

        public required override init(_ reader: BinaryDataReader?, offset: Int? = nil, table: FontTable) throws {
            try super.init(reader, offset: offset, table: table)
            if let reader {
                startCharCode = try reader.read()
                endCharCode = try reader.read()
                startGlyphID = try reader.read()
            }
        }
    }
}

//
//  Subtable2.Segment.swift
//  CoreFont
//
//  Created by Mark Douma on 2/24/2026.
//

import Foundation
import RFSupport

extension FontTable_cmap.Subtable2 {

    public class Segment: FontTableNode {
        public var firstCode:       UInt16 = 0
        public var entryCount:      UInt16 = 0
        public var idDelta:         Int16 = 0
        public var idRangeOffset:   UInt16 = 0

        public override class var nodeLength: UInt32 { 8 }

        public override init(_ reader: BinaryDataReader?, offset: Int? = nil, table: FontTable) throws {
            try super.init(reader, offset: offset, table: table)
            if let reader {
                firstCode = try reader.read()
                entryCount = try reader.read()
                idDelta = try reader.read()
                idRangeOffset = try reader.read()
            }
        }
    }
}

//
//  Format2_5.swift
//  CoreFont
//
//  Created by Mark Douma on 1/21/2026.
//

import Foundation
import RFSupport

public extension FontTable_post {

    // uses standard 258 Apple Glyph Names, but has different order; deprecated
    final class Format2_5: Format {

        public var numberOfGlyphs:          UInt16 = 0      // must be synched with maxp.numGlyphs
        public var offsets:                	[UInt8] = []

        required public init(_ reader: BinaryDataReader!, offset: Int? = nil, table: FontTable? = nil) throws {
            try super.init(reader, offset: offset, table: table)
            numberOfGlyphs = try reader.read()

        }
    }

}

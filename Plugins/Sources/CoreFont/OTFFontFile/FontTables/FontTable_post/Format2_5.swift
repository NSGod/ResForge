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

        public var numberOfGlyphs:          UInt16 = 0  // must be synched with maxp.numGlyphs
        public var offsets:                	[Int8] = []

        required public init(_ reader: BinaryDataReader, offset: Int? = nil, table: FontTable? = nil) throws {
            try super.init(reader, offset: offset, table: table)
            numberOfGlyphs = try reader.read()
            for i in 0..<Int(numberOfGlyphs) {
                var iOffset: Int8 = try reader.read()
                let index: Int = i + Int(iOffset)
                if index > appleStdGlyphNames.count - 1 {
                    NSLog("\(type(of: self)).\(#function) *** WARNING: invalid glyph name index (\(index))")
                } else {
                    let entry = GlyphEntry(glyphID: GlyphID(i), glyphName: appleStdGlyphNames[index])
                    glyphEntries.append(entry)
                    glyphIDsToEntries[Glyph32ID(i)] = entry
                }
#warning("Incomplete")

//                iOffs
            }
        }
    }

}

//
//  Format2_0.swift
//  CoreFont
//
//  Created by Mark Douma on 1/21/2026.
//

import Foundation
import RFSupport

public extension FontTable_post {

    final class Format2_0: Format {
        public var numberOfGlyphs:          UInt16 = 0      // must be synched with maxp.numGlyphs
        public var glyphNameIndexes:        [GlyphID] = []

        required public init(_ reader: BinaryDataReader, offset: Int? = nil, table: FontTable? = nil) throws {
            try super.init(reader, offset: offset, table: table)
            numberOfGlyphs = try reader.read()
            for _ in 0..<numberOfGlyphs {
                let glyphID: GlyphID = try reader.read()
                glyphNameIndexes.append(glyphID)
            }
            while (reader.bytesRemaining > 0) {
                let glyphName = try reader.readPString()
                glyphNames.append(glyphName)
            }
            let glyphNamesCount = glyphNames.count
            for i: GlyphID in 0..<numberOfGlyphs {
                let index: UInt16 = glyphNameIndexes[Int(i)]
                let entry: GlyphEntry
                // FIXME: is this right? or shouldn't it be UInt16.max?
                if index > 32767 {
                    NSLog("\(type(of: self)).\(#function) *** WARNING: glyphNameIndex[\(i)] contains an invalid name index (\(index))")
                    entry = GlyphEntry(glyphID: i, glyphName: appleStdGlyphNames[0])
                } else if index > appleStdGlyphNames.count - 1 {
                    let altIndex: UInt16 = index - UInt16(appleStdGlyphNames.count)
                    if altIndex > glyphNamesCount {
                        // FIXME: better error
                        throw FontTableError.parseError(nil)
                    } else {
                        entry = GlyphEntry(glyphID: i, glyphName: glyphNames[Int(altIndex)])
                    }
                } else {
                    entry = GlyphEntry(glyphID: i, glyphName: appleStdGlyphNames[Int(index)])
                }
                glyphEntries.append(entry)
                glyphIDsToEntries[Glyph32ID(i)] = entry
            }
        }
    }
}

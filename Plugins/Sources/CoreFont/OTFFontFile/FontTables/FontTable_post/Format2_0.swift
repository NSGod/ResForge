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
        // public var glyphNames:           [String]        // inherited

        public required init(_ reader: BinaryDataReader, offset: Int? = nil, table: FontTable) throws {
            try super.init(reader, offset: offset, table: table)
            numberOfGlyphs = try reader.read()
            glyphNameIndexes = try (0..<numberOfGlyphs).map { _ in try reader.read() }
            while (reader.bytesRemaining > 0) {
                let glyphName = try reader.readPString()
                glyphNames.append(glyphName)
            }
            let glyphNamesCount = glyphNames.count
            for i: GlyphID in 0..<numberOfGlyphs {
                let index: UInt16 = glyphNameIndexes[Int(i)]
                let entry: GlyphEntry
                /// - Note: the correct value to use here is indeed `Int16.max` and not `UInt16.max`,
                /// since the standard states that "Index numbers 32768 through 65535 are reserved for future use.":
                /// https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6post.html
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

        public override func write(to dataHandle: DataHandle) throws {
            dataHandle.write(numberOfGlyphs)
            glyphNameIndexes.forEach { dataHandle.write($0) }
            try glyphNames.forEach { try dataHandle.writePString($0) }
        }
    }
}

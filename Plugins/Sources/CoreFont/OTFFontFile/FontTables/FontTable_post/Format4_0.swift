//
//  Format4_0.swift
//  CoreFont
//
//  Created by Mark Douma on 1/21/2026.
//

import Foundation
import RFSupport

public extension FontTable_post {

    final class Format4_0: Format {
        var codes:                  [UInt16] = []

        public required init(_ reader: BinaryDataReader, offset: Int? = nil, table: FontTable) throws {
            try super.init(reader, offset: offset, table: table)
            let numGlyphs = table.fontNumGlyphs
            var code: UInt16 = 0
            for _ in 0..<numGlyphs {
                code = try reader.read()
                codes.append(code)
            }
            for i in 0..<numGlyphs {
                let entry: GlyphEntry = GlyphEntry(glyphID: UInt16(i), code: codes[i] as NSNumber)
                glyphEntries.append(entry)
                glyphIDsToEntries[Glyph32ID(i)] = entry
            }
        }

        public override func write(to dataHandle: DataHandle) throws {
            codes.forEach { dataHandle.write($0) }
        }
    }
}

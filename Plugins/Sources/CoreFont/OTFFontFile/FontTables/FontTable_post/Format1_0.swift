//
//  Format1_0.swift
//  CoreFont
//
//  Created by Mark Douma on 1/21/2026.
//

import Foundation
import RFSupport

public extension FontTable_post {

    final class Format1_0: Format {
        // Format 1.0 uses the standard 258 Apple glyph names in that order and requires no storage
        required public init(_ reader: BinaryDataReader, offset: Int? = nil, table: FontTable? = nil) throws {
            try super.init(reader, offset: offset, table: table)
            glyphEntries.append(contentsOf: GlyphEntry.standardAppleGlyphEntries)
            for entry in glyphEntries {
                glyphIDsToEntries[Glyph32ID(entry.glyphID)] = entry
                if let glyphName = entry.glyphName {
                    glyphNames.append(glyphName)
                }
            }
        }
    }

}

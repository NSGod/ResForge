//
//  EmptyGlyph.swift
//  CoreFont
//
//  Created by Mark Douma on 4/3/2026.
//

import Foundation
import RFSupport

extension FontTable_glyf {
    
    public final class EmptyGlyph: Glyph {
        required init(_ reader: BinaryDataReader, location: FontTable_loca.GlyphLocation, glyphID: GlyphID, table: FontTable_glyf) throws {
            try super.init(reader, location: location, glyphID: glyphID, table: table)
            isEmpty = true
        }
    }
}

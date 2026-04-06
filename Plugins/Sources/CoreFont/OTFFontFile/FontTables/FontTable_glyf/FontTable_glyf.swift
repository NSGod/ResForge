//
//  FontTable_glyf.swift
//  CoreFont
//
//  Created by Mark Douma on 4/3/2026.
//

import Foundation
import RFSupport

public final class FontTable_glyf: FontTable {
    public var glyphs:      [Glyph] = []

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        guard let glyphLocations = locaTable?.glyphLocations else {
            throw FontTableError.parseError("Missing glyf.loca table")
        }
        var glyphID: GlyphID = 0
        for glyphLocation in glyphLocations {
            try reader.setPosition(glyphLocation.offset)
            /// correct subclass type of Glyph is chosen automatically
            let glyph = try Glyph.glyph(reader, location: glyphLocation, glyphID: glyphID, table: self)
            glyphs.append(glyph)
            glyphID += 1
        }
        /// resolve compound glyphs
        glyphs.forEach { $0.awakeFromFont() }
    }



}

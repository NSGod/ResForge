//
//  Sbit.BitmapStrike.swift
//  CoreFont
//
//  Created by Mark Douma on 3/25/2026.
//

import Cocoa
import RFSupport

/// "OFF embedded bitmaps are also called 'sbits' (for “scaler bitmaps”).
/// A set of bitmaps for a face at a given size is called a strike."

extension Sbit {

    /// in `bdat`/`EBDT` table
    public final class BitmapStrike: Node {
        public var sizeTable:               BitmapSizeTable
        public var glyphs:                  [BitmapGlyph] = []
        private var glyphIDsToGlyphs:       [GlyphID: BitmapGlyph] = [:]
        public weak var fontFile:           OTFFontFile!

        public required init(_ reader: BinaryDataReader, sizeTable: BitmapSizeTable) throws {
            self.sizeTable = sizeTable
            let isHorizontal = sizeTable.flags.contains(.horizontal)
            for indexSubtableArray in sizeTable.indexSubtableArrays {
                var bitmapGlyphs: [BitmapGlyph] = []
                let imageDataOffset = indexSubtableArray.indexSubtable.imageDataOffset
                let imageFormat = indexSubtableArray.indexSubtable.imageFormat
                for (glyphID, range) in indexSubtableArray.indexSubtable.format.glyphIDsToRanges {
                    let glyph = try BitmapGlyph(reader, imageDataOffset: imageDataOffset, range: range, glyphID: glyphID, imageFormat: imageFormat, horizontalMetrics: isHorizontal)
                    bitmapGlyphs.append(glyph)
                    glyphIDsToGlyphs[glyphID] = glyph
                }
                if imageFormat == .mono, let monospacedMetrics = indexSubtableArray.indexSubtable.format.monospacedMetrics {
                    bitmapGlyphs.forEach { $0.metrics = GlyphMetrics(monospacedMetrics) }
                }
                glyphs.append(contentsOf: bitmapGlyphs)
            }
            try super.init(reader)
            glyphs.forEach { $0.strike = self }
            glyphs.sort(by: <)
            glyphs.forEach { glyphIDsToGlyphs[$0.glyphID] = $0 }
            glyphs.forEach { $0.awakeFromFont() }
        }

        @available(*, unavailable, message: "use init that takes a sizeTable")
        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            fatalError("use init that takes a sizeTable")
        }

        public func glyph(for glyphID: GlyphID) -> BitmapGlyph? {
            return glyphIDsToGlyphs[glyphID]
        }
    }
}

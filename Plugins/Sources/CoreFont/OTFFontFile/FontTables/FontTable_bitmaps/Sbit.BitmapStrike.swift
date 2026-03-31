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

    /// in `bdat` table
    public final class BitmapStrike: Node {
        public var sizeTable:               BitmapSizeTable
        public var glyphs:                  [BitmapGlyph] = []
        public weak var fontFile:           OTFFontFile!

        public required init(_ reader: BinaryDataReader, sizeTable: BitmapSizeTable) throws {
            self.sizeTable = sizeTable
            let imageDataOffset = sizeTable.indexSubtableArray.indexSubtable.imageDataOffset
            let imageFormat = sizeTable.indexSubtableArray.indexSubtable.imageFormat
            let isHorizontal = sizeTable.flags.contains(.horizontal)
            for (glyphID, range) in sizeTable.indexSubtableArray.indexSubtable.format.glyphIDsToRanges {
                let glyph = try BitmapGlyph(reader, imageDataOffset: imageDataOffset, range: range, glyphID: glyphID, imageFormat: imageFormat, horizontalMetrics: isHorizontal)
                glyphs.append(glyph)
            }
            try super.init(reader)
            glyphs.forEach { $0.strike = self }
            if imageFormat == .mono, let monospacedMetrics = sizeTable.indexSubtableArray.indexSubtable.format.monospacedMetrics {
                glyphs.forEach { $0.metrics = GlyphMetrics(monospacedMetrics) }
            }
            glyphs.sort(by: <)
            glyphs.forEach { $0.awakeFromFont() }
        }

        @available(*, unavailable, message: "use init that takes a sizeTable")
        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            fatalError("use init that takes a sizeTable")
        }

        public func glyph(for glyphID: GlyphID) -> BitmapGlyph {
            return glyphs[Int(glyphID)]
        }
    }
}

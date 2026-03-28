//
//  BitmapStrike.swift
//  CoreFont
//
//  Created by Mark Douma on 3/25/2026.
//

import Cocoa
import RFSupport

public final class BitmapStrike: Node {
    public var sizeTable:               FontTable_bloc.BitmapSizeTable
    public var format:                  Sbit.BitmapGlyphFormat
    public var glyphs:                  [BitmapGlyph]
    public weak var fontFile:           OTFFontFile!

    public required init(_ reader: BinaryDataReader, offset: Int? = nil, sizeTable: FontTable_bloc.BitmapSizeTable) throws {
        assert(offset == nil)
        self.sizeTable = sizeTable
        let offset = Int(sizeTable.indexSubtableArray.indexSubtable.imageDataOffset)
        guard let formatClass = Sbit.BitmapGlyphFormat.class(for: sizeTable.indexSubtableArray.indexSubtable.imageFormat) else {
            throw FontTableError.unknownFormat("Unsupported bitmap format: \(sizeTable.indexSubtableArray.indexSubtable.imageFormat)")
        }
        format = try formatClass.init(reader, sizeTable: sizeTable)
        glyphs = format.glyphs
        try super.init(reader, offset: offset)
        glyphs.forEach { $0.strike = self }
        if sizeTable.indexSubtableArray.indexSubtable.imageFormat == .mono {
            if let monospacedMetrics = sizeTable.indexSubtableArray.indexSubtable.format.monospacedMetrics {
                glyphs.forEach { $0.metrics = Sbit.GlyphMetrics(monospacedMetrics) }
            }
        }
    }

    @available(*, unavailable, message: "use init that takes a sizeTable")
    public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
        fatalError("use init that takes a sizeTable")
    }
}

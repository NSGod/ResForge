//
//  BitmapStrike.swift
//  CoreFont
//
//  Created by Mark Douma on 3/25/2026.
//

import Cocoa
import RFSupport

public final class BitmapStrike: Node {
    public var ppemX:                   UInt8
    public var ppemY:                   UInt8

    public var horizontalMetrics:       Sbit.LineMetrics
    public var verticalMetrics:         Sbit.LineMetrics

    public var bitDepth:                FontTable_bloc.BitmapSizeTable.BitDepth
    public var format:                  Sbit.BitmapGlyphFormat
    public var glyphs:                  [BitmapGlyph]

    public required init(_ reader: BinaryDataReader, offset: Int? = nil, sizeTable: FontTable_bloc.BitmapSizeTable) throws {
        assert(offset == nil)
        ppemX = sizeTable.ppemX
        ppemY = sizeTable.ppemY
        bitDepth = sizeTable.bitDepth
        horizontalMetrics = sizeTable.hori
        verticalMetrics = sizeTable.vert
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

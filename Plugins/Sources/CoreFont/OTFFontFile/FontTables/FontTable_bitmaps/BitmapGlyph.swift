//
//  BitmapGlyph.swift
//  CoreFont
//
//  Created by Mark Douma on 3/25/2026.
//

import Cocoa
import RFSupport

public class BitmapGlyph: Node, Comparable {
    public var glyphID:         GlyphID

    public var data:            Data

    public var metrics:         Sbit.GlyphMetrics!
    public weak var strike:     BitmapStrike!


    public lazy var image:      NSImage? = {




        return nil
    }()




    public required init(_ reader: BinaryDataReader, offset: UInt32, range: Range<UInt32>, glyphID: GlyphID) throws {
        self.glyphID = glyphID
        data = try reader.subdata(with: (offset + range.lowerBound)..<(offset + range.upperBound))
        try super.init(reader)
    }

    @available(*, unavailable, message: "Use init(_:offset:range:glyphID:) instead")
    public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
        fatalError("Use init(_:offset:range:glyphID:) instead")
    }

    public static func < (lhs: BitmapGlyph, rhs: BitmapGlyph) -> Bool {
        lhs.glyphID < rhs.glyphID
    }

    public static func == (lhs: BitmapGlyph, rhs: BitmapGlyph) -> Bool {
        return lhs.glyphID == rhs.glyphID
    }
}

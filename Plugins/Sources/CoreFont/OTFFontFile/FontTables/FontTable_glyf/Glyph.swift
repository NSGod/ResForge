//
//  Glyph.swift
//  CoreFont
//
//  Created by Mark Douma on 4/3/2026.
//

import Cocoa
import RFSupport

extension FontTable_glyf {

    /// abstract superclass
    public class Glyph: FontTableNode, FontAwaking {
        public var numberOfContours:    Int16 = 0
        public var xMin:                Int16 = 0
        public var yMin:                Int16 = 0
        public var xMax:                Int16 = 0
        public var yMax:                Int16 = 0

        public var isEmpty:             Bool = false
        public var isCompound:          Bool = false

        public var coordinates:         Coordinates?
        public var bezierPath:          NSBezierPath?

        internal required init(_ reader: BinaryDataReader, location: FontTable_loca.GlyphLocation, glyphID: GlyphID, table: FontTable_glyf) throws {
            try super.init(reader, table: table)
            /// allow empty glyph to succeed
            if location.length == 0 { return }
            numberOfContours = try reader.read()
            xMin = try reader.read()
            yMin = try reader.read()
            xMax = try reader.read()
            yMax = try reader.read()
        }

        public static func glyph(_ reader: BinaryDataReader, location: FontTable_loca.GlyphLocation, glyphID: GlyphID, table: FontTable_glyf) throws -> Glyph {
            guard location.length == 0 else {
                return try EmptyGlyph(reader, location: location, glyphID: glyphID, table: table)
            }
            let numberOfContours: Int16 = try reader.peek()
            if numberOfContours > 0 {
                return try SimpleGlyph(reader, location: location, glyphID: glyphID, table: table)
            } else if numberOfContours == -1 {
                return try CompoundGlyph(reader, location: location, glyphID: glyphID, table: table)
            } else {
                throw FontTableError.parseError("unexpected numberOfContours: \(numberOfContours) for glyphID: \(glyphID)")
            }
        }

        @available(*, unavailable, message: "use `init(_:location:glyphID:table:)")
        public override init(_ reader: BinaryDataReader? = nil, offset: Int? = nil, table: FontTable) throws {
            fatalError("use `init(_:location:glyphID:table:)")
        }

        public func awakeFromFont() { }

    }
}

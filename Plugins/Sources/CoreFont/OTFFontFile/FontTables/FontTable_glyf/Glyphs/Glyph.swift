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
    public class Glyph: FontTableNode, FontAwaking, UIGlyph {

        public var numberOfContours:        Int16 = 0

        /// these should be `Int16`s, but to conform to `UIGlyph`, we need `CGFloat`
        // public var xMin:                    Int16 = 0
        // public var yMin:                    Int16 = 0
        // public var xMax:                    Int16 = 0
        // public var yMax:                    Int16 = 0
        public var xMin:                    CGFloat = 0
        public var yMin:                    CGFloat = 0
        public var xMax:                    CGFloat = 0
        public var yMax:                    CGFloat = 0

        public var isEmpty:                 Bool = false
        public var isCompound:              Bool = false

        public var coordinates:             Coordinates?
        public var bezierPath:              NSBezierPath? {
            return nil
        }

        public let glyphID:                 GlyphID
        public var glyphName:               String = ""

//        public var glyphName:               String {
//            self.table.fontGlyphName(for: glyphID) ?? "<\(glyphID)>"
//        }

        public var uv: UV = .undefined
        public var additionalUVs: IndexSet?
        public var allUVs: IndexSet?

        public var advanceWidth:            CGFloat {
            return CGFloat(horizontalMetric?.advanceWidth ?? 0)
        }

        public lazy var horizontalMetric:   HorizontalMetric? = {
            return table.hmtxTable?.metric(for: glyphID)
        }()

        public lazy var verticalMetric:     VerticalMetric? = {
            return table.vmtxTable?.metric(for: glyphID)
        }()

        public weak var glyphsProvider: (any UIGlyphsProvider)! {
            return table.fontFile
        }

        public weak var metricsProvider: (any UIMetricsProvider)! {
            return table.fontFile
        }

        internal required init(_ reader: BinaryDataReader, location: FontTable_loca.GlyphLocation, glyphID: GlyphID, table: FontTable_glyf) throws {
            self.glyphID = glyphID
            try super.init(reader, table: table)
            /// allow empty glyph to succeed
            if location.length == 0 { return }
            numberOfContours = try reader.read()
            xMin = CGFloat(try reader.read() as Int16)
            yMin = CGFloat(try reader.read() as Int16)
            xMax = CGFloat(try reader.read() as Int16)
            yMax = CGFloat(try reader.read() as Int16)
        }

        public static func glyph(_ reader: BinaryDataReader, location: FontTable_loca.GlyphLocation, glyphID: GlyphID, table: FontTable_glyf) throws -> Glyph {
            if location.length == 0 {
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

//
//  Contour.swift
//  CoreFont
//
//  Created by Mark Douma on 4/4/2026.
//

import Cocoa

extension FontTable_glyf {

    public final class Contour {
        public var points:          [Point] = []

        public var numPoints:       Int {
            return points.count
        }

        public var xMin:            Int16 = 0
        public var yMin:            Int16 = 0
        public var xMax:            Int16 = 0
        public var yMax:            Int16 = 0

        /// parent glyph
        public weak var glyph:      Glyph?

        public init(points: [Point], glyph: SimpleGlyph?, table: FontTable) throws {

//            try super.init(table: table)
        }

        public static func contoursWith(xCoordinates: [Int], yCoordinates: [Int], endPointIndexes: IndexSet, flags: [Flags], glyph: SimpleGlyph?, table: FontTable) throws -> [Contour] {
            return []
        }
        
        public static func bezierPathRepresentation(of contours: [Contour], glyph: SimpleGlyph) throws -> NSBezierPath? {

            return nil
        }
    }
}

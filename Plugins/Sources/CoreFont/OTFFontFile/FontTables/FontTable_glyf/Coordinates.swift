//
//  Coordinates.swift
//  CoreFont
//
//  Created by Mark Douma on 4/4/2026.
//

import Cocoa

extension FontTable_glyf {
    
    // MARK: this class represents the expanded points with flags
    public struct Coordinates: Copyable {
        public enum CoordType {
            case absolute
            case relative
        }

        public var points:          [Point] = []

        public var numPoints:       Int {
            return points.count
        }

        /// - Note: glyphs can have "single-point" contours to be used
        ///    with compound glyph component point index matching
        public var contours:        [Contour]?

//        public var flags:           [Flags] = []
//        public var xCoordinates:    [Int] = []
//        public var yCoordinates:    [Int] = []

//        public var endPointIndexes: IndexSet

        public var xMin:            Int16 = 0
        public var yMin:            Int16 = 0
        public var xMax:            Int16 = 0
        public var yMax:            Int16 = 0

        public var type:            CoordType = .absolute

        public var isAbsolute:      Bool { type == .absolute }
        public var isRelative:      Bool { type == .relative }

        public init(xCoordinates: [Int], yCoordinates: [Int], endPointIndexes: IndexSet, flags: [Flags], numPoints: Int, type: CoordType, glyph: SimpleGlyph?, table: FontTable) throws {
            assert(xCoordinates.count == yCoordinates.count && yCoordinates.count == flags.count && flags.count == numPoints)
            self.type = type
//            self.flags = flags
//            self.xCoordinates = xCoordinates
//            self.yCoordinates = yCoordinates
//            self.endPointIndexes = endPointIndexes
            self.contours = try Contour.contoursWith(xCoordinates: xCoordinates, yCoordinates: yCoordinates, endPointIndexes: endPointIndexes, flags: flags)
            if let contours {
                self.points = contours.flatMap { $0.points }
            }
            calculateBounds()
            let hMetric = glyph?.horizontalMetric
            let vMetric = glyph?.verticalMetric
            /// Check to see if current coordinates abide by glyph metrics (left/top sidebearing)
            /// If it doesn't, create a transform to shift them
            let transform: AffineTransform
            if let hMetric {
                if xMin != hMetric.leftSideBearing {
                    transform = AffineTransform(translationByX: CGFloat(hMetric.leftSideBearing - xMin), byY: 0)
                }
            } else if let vMetric {
                // FIXME: !! not sure if this is right
                if yMin != vMetric.topSideBearing {
                    transform = AffineTransform(translationByX: 0, byY: CGFloat(vMetric.topSideBearing - yMin))
                }
            }
        }

        public subscript (index: Int) -> Point {
            return points[index]
        }

        /// copies the receiver's coordinate's points:
        public func append(_ coordinates: Coordinates) {

        }

        public func translate(xBy: CGFloat, yBy: CGFloat) {

        }

        public func transform(using transform: AffineTransform) {

        }

        private mutating func calculateBounds() {
            xMin = .max; yMin = .max; xMax = .min; yMax = .min
            for point in points {
                xMin = min(xMin, Int16(point.x))
                yMin = min(yMin, Int16(point.y))
                xMax = max(xMax, Int16(point.x))
                yMax = max(yMax, Int16(point.y))
            }
        }

        public mutating func convertAbsoluteToRelative() {

        }

        public mutating func convertRelativeToAbsolute() {

        }

        public static func bezierPathRepresentation(of contours: [Contour], glyph: SimpleGlyph) throws -> NSBezierPath? {

            return nil
        }
    }
}

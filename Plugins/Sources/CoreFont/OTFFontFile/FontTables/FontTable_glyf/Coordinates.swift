//
//  Coordinates.swift
//  CoreFont
//
//  Created by Mark Douma on 4/4/2026.
//

import Cocoa

extension FontTable_glyf {

    // MARK: this class represents the expanded points with flags
    public struct Coordinates {
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

        // public var flags:           [Flags] = []
        // public var xCoordinates:    [Int] = []
        // public var yCoordinates:    [Int] = []

        public var endPointIndexes: IndexSet

        public var xMin:            Int16 = 0
        public var yMin:            Int16 = 0
        public var xMax:            Int16 = 0
        public var yMax:            Int16 = 0

        public private(set) var type:   CoordType = .absolute

        public var isAbsolute:      Bool { type == .absolute }
        public var isRelative:      Bool { type == .relative }

        public init(xCoordinates: [Int], yCoordinates: [Int], endPointIndexes: IndexSet, flags: [Flags], numPoints: Int, type: CoordType, glyph: SimpleGlyph?, table: FontTable) throws {
            assert(xCoordinates.count == yCoordinates.count && yCoordinates.count == flags.count && flags.count == numPoints)
            self.type = type
            self.endPointIndexes = endPointIndexes
            self.contours = try Contour.contoursWith(xCoordinates: xCoordinates, yCoordinates: yCoordinates, endPointIndexes: endPointIndexes, flags: flags)
            if let contours {
                self.points = contours.flatMap { $0.points }
            }
            calculateBounds()
            let hMetric = glyph?.horizontalMetric
            let vMetric = glyph?.verticalMetric
            /// Check to see if current coordinates abide by glyph metrics (left/top sidebearing)
            /// If it doesn't, create a transform to shift them
            var transform: AffineTransform?
            if let hMetric {
                if xMin != hMetric.leftSideBearing {
                    transform = AffineTransform(translationByX: CGFloat(hMetric.leftSideBearing - xMin), byY: 0)
                }
            } else if let vMetric {
                // FIXME: !! not sure if this is right
                if yMin != vMetric.topSideBearing {
                    /// or should this be `- yMax`?
                    transform = AffineTransform(translationByX: 0, byY: CGFloat(vMetric.topSideBearing - yMin))
                }
            }
            if let transform {
                self.transform(using: transform)
            }
        }

        public subscript (index: Int) -> Point {
            return points[index]
        }

        public mutating func append(_ coordinates: Coordinates) {
            assert(type == coordinates.type)
            if var contours, let coordContours = coordinates.contours {
                contours.append(contentsOf: coordContours)
            } else {
                contours = coordinates.contours
            }
            var shiftedIndexes = coordinates.endPointIndexes
            guard let first = shiftedIndexes.first, let delta = endPointIndexes.last else { return }
            shiftedIndexes.shift(startingAt: first, by: delta + 1)
            endPointIndexes.formUnion(shiftedIndexes)
            if let contours {
                points = contours.flatMap(\.points)
            }
            calculateBounds()
        }

        public mutating func translate(x deltaX: CGFloat, y deltaY: CGFloat) {
            /// must update our points and contours' points
            if deltaX == 0.0 && deltaY == 0.0 { return }
            contours?.forEach { contour in var mContour = contour; mContour.translate(x: deltaX, y: deltaY)}
            points.forEach { point in var mPoint = point; mPoint.translate(x: deltaX, y: deltaY) }
            calculateBounds()
        }

        public mutating func transform(using transform: AffineTransform) {
            /// must update our points and contours' points
            if transform == .identity { return }
            contours?.forEach { contour in var mContour = contour; mContour.transform(using: transform) }
            points.forEach { point in var mPoint = point; mPoint.transform(using: transform) }
            calculateBounds()
        }

        public static func * (lhs: Coordinates, rhs: CGFloat) -> Coordinates {
            var coordinates = lhs
            coordinates.points.forEach { point in var mPoint = point; mPoint *= rhs }
            coordinates.contours?.forEach { contour in var mContour = contour; mContour *= rhs }
            coordinates.calculateBounds()
            return coordinates
        }

        public static func *= (lhs: inout Coordinates, rhs: CGFloat) {
            lhs = lhs * rhs
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
    }
}

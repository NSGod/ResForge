//
//  Coordinates.swift
//  CoreFont
//
//  Created by Mark Douma on 4/4/2026.
//

import Cocoa

extension FontTable_glyf {
    
    // MARK: this class represents the expanded points with flags
    public final class Coordinates {
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

        public var flags:           [Flags] = []
        public var xCoordinates:    [Int] = []
        public var yCoordinates:    [Int] = []

        public var endPointIndexes: IndexSet

        public var xMin:            Int16 {
            calculateBoundsIfNeeded()
            return _xMin
        }

        public var yMin:            Int16 {
            calculateBoundsIfNeeded()
            return _yMin
        }

        public var xMax:            Int16 {
            calculateBoundsIfNeeded()
            return _xMax
        }

        public var yMax:            Int16 {
            calculateBoundsIfNeeded()
            return _yMax
        }

        public var type:            CoordType = .absolute

        public var isAbsolute:      Bool { type == .absolute }
        public var isRelative:      Bool { type == .relative }

        private var _calculatedBounds: Bool = false
        private var _xMin: Int16 = 0
        private var _yMin: Int16 = 0
        private var _xMax: Int16 = 0
        private var _yMax: Int16 = 0

        public init(xCoordinates: [Int], yCoordinates: [Int], endPointIndexes: IndexSet, flags: [Flags], numPoints: Int, type: CoordType, glyph: SimpleGlyph?, table: FontTable) throws {
            assert(xCoordinates.count == yCoordinates.count && yCoordinates.count == flags.count && flags.count == numPoints)
            self.type = type
//            self.numPoints = numPoints
            self.endPointIndexes = endPointIndexes
            self.contours = try Contour.contoursWith(xCoordinates: xCoordinates, yCoordinates: yCoordinates, endPointIndexes: endPointIndexes, flags: flags, glyph: glyph, table: table)
            if let contours {
                self.points = contours.flatMap { $0.points }
            }
            _xMin = Int16.max; _yMin = Int16.max
            _xMax = Int16.min; _yMax = Int16.min
            calculateBoundsIfNeeded()

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

        private func calculateBoundsIfNeeded() {
            if _calculatedBounds { return }
            _xMin = Int16.max; _yMin = Int16.max
            _xMax = Int16.min; _yMax = Int16.min
            for point in points {
                _xMin = min(_xMin, Int16(point.x))
                _yMin = min(_yMin, Int16(point.y))
                _xMax = max(_xMax, Int16(point.x))
                _yMax = max(_yMax, Int16(point.y))
            }
            _calculatedBounds = true
        }

        private func clearBoundsIfNeeded() {
            if !_calculatedBounds { return }
            _xMin = Int16.max; _yMin = Int16.max
            _xMax = Int16.min; _yMax = Int16.min
            _calculatedBounds = false
        }

        public func convertAbsoluteToRelative() {

        }

        public func convertRelativeToAbsolute() {

        }

        public static func bezierPathRepresentation(of contours: [Contour], glyph: SimpleGlyph) throws -> NSBezierPath? {

            return nil
        }
    }
}

//
//  Contour.swift
//  CoreFont
//
//  Created by Mark Douma on 4/4/2026.
//
/// Part of this code is adapted from Adobe's Font Development Kit for OpenType (AFDKO):
/// https://github.com/NSGod/afdko/blob/develop/c/spot/glyf.c#L643
///
/* Copyright 2014 Adobe Systems Incorporated (http://www.adobe.com/). All Rights Reserved.
   This software is licensed as OpenSource, under the Apache License, Version 2.0.
   This license is available at: http://opensource.org/licenses/Apache-2.0. */

import Cocoa

extension FontTable_glyf {

    public struct Contour {
        public var points:          [Point]

        public var numPoints:       Int {
            return points.count
        }

        public var xMin:            Int16 = 0
        public var yMin:            Int16 = 0
        public var xMax:            Int16 = 0
        public var yMax:            Int16 = 0

        public init(points: [Point]) throws {
            self.points = points
            calculateBounds()
        }

        public static func contoursWith(xCoordinates: [Int], yCoordinates: [Int], endPointIndexes: IndexSet, flags: [Flags]) throws -> [Contour] {
            var mContours: [Contour] = []
            var i = 0
            for endPointIndex in endPointIndexes {
                var mPoints: [Point] = []
                for j in i..<endPointIndex + 1 {
                    mPoints.append(Point(point: NSMakePoint(CGFloat(xCoordinates[j]), CGFloat(yCoordinates[j])), flags: flags[j]))
                    i += 1
                }
                try mContours.append(Contour(points: mPoints))
            }
            return mContours
        }

        public subscript (index: Int) -> Point {
            return points[index]
        }

        public static func bezierPathRepresentation(of contours: [Contour], glyph: SimpleGlyph) -> NSBezierPath? {
            /* from /afdko/c/spot/source/glyf.c: */

            /* Draw path. This algorithm uses the point before (pt0) and the current point
               (pt1) in order to determine what PostScript path operators to emit. Any point
               can be on or off the curve giving 4 cases:

               pt0   pt1      Action
               --   --      ------
               off  off     End one Bezier curve and begin another.
               off  on      End Bezier curve.
               on   off     Begin Bezier curve.
               on   on      Draw line.

               The point after the current point (pt2) is only used for determining tic mark
               orientation. */
            var pt0: Point  /// previous point
            var pt1: Point  /// current point
            var pt2: Point  /// next point
            var workingPoint: NSPoint = .zero
            var iStart = 0 // start coordinate index
            let bPathRep = NSBezierPath()
            for contour in contours {
                assert(contour.numPoints > 0)
                let iEnd = contour.points.count - 1
                pt0 = contour.points.last!
                pt1 = contour.points.first!
                if iStart == iEnd {
                    // single point and/or empty contour
                } else {
                    var nSegs = contour.points.count
                    var i2 = iStart + 1 /// next coordinate index
                    pt2 = contour[i2]
                    if pt1.isOnCurve {
                        bPathRep.move(to: pt1.point)
                    } else {
                        if pt0.isOnCurve {
                            /// back up to previous point
                            pt2 = pt1
                            pt1 = pt0
                            i2 = iStart
                            bPathRep.move(to: pt1.point)
                        } else {
                            bPathRep.move(to: NSMakePoint((pt0.x + pt1.x) / 2.0,
                                                          (pt0.y + pt1.y) / 2.0))
                            workingPoint = NSMakePoint((pt0.x + 5 * pt1.x) / 6.0,
                                                       (pt0.y + 5 * pt1.y) / 6.0)
                        }
                    }
                    /// output segments
                    while nSegs > 0 {
                        pt0 = pt1
                        pt1 = pt2
                        /// get next point
                        i2 += 1
                        if i2 > iEnd {
                            i2 = iStart /// wrap around
                        }
                        pt2 = contour[i2]
                        if pt0.isOnCurve {
                            if pt1.isOnCurve {
                                /// on on
                                /// draw line
                                bPathRep.line(to: pt1.point)
                            } else {
                                /// on off
                                /// begin bezier curve
                                workingPoint = NSMakePoint((pt0.x + 2 * pt1.x) / 3.0,
                                                           (pt0.y + 2 * pt1.y) / 3.0)
                            }
                        } else {
                            if pt1.isOnCurve {
                                /// off on
                                /// end bezier path
                                bPathRep.curve(to: pt1.point, controlPoint1: workingPoint, controlPoint2: NSMakePoint((2 * pt0.x + pt1.x) / 3.0,
                                                                                                                      (2 * pt0.y + pt1.y) / 3.0))
                            } else {
                                /// off off
                                /// end one bezier curve and begin another
                                let x = (pt0.x + pt1.x) / 2.0
                                let y = (pt0.y + pt1.y) / 2.0
                                bPathRep.curve(to: NSMakePoint(x, y), controlPoint1: workingPoint, controlPoint2: NSMakePoint((5 * pt0.x + pt1.x) / 6.0,
                                                                                                                              (5 * pt0.y + pt1.y) / 6.0))
                                if nSegs != 0 {
                                    workingPoint = NSMakePoint((pt0.x + 5 * pt1.x) / 6.0,
                                                               (pt0.y + 5 * pt1.y) / 6.0)
                                }
                            }
                        }
                        nSegs -= 1
                    }
                }
                iStart = iEnd + 1
            }
            let hMetric = glyph.horizontalMetric
            let vMetric = glyph.verticalMetric
            let bounds = bPathRep.bounds
            /// Check to see if the current path representation abides by the glyph metrics
            /// if it doesn't, create a transform to shift it
            var transform: AffineTransform?
            if let hMetric {
                if bounds.minX != CGFloat(hMetric.leftSideBearing) {
                    transform = AffineTransform(translationByX:CGFloat(hMetric.leftSideBearing) - bounds.minX, byY: 0)
                }
            } else if let vMetric {
                // FIXME: !! not sure if this is right
                if bounds.maxY != CGFloat(vMetric.topSideBearing) {
                    /// or should this be `- bounds.maxY`?
                    transform = AffineTransform(translationByX: 0, byY: CGFloat(vMetric.topSideBearing) - bounds.minY)
                }
            }
            if let transform {
                bPathRep.transform(using: transform)
            }
            return bPathRep
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

        public mutating func translate(x: CGFloat, y: CGFloat) {
            points.forEach { point in var mPoint = point; mPoint.translate(x: x, y: y) }
            calculateBounds()
        }

        public mutating func transform(using transform: AffineTransform) {
            points.forEach { point in var mPoint = point; mPoint.transform(using: transform) }
            calculateBounds()
        }

        public static func * (lhs: Contour, rhs: CGFloat) -> Contour {
            var contour = lhs
            contour.points.forEach { point in var mPoint = point; mPoint *= rhs }
            contour.calculateBounds()
            return contour
        }

        public static func *= (lhs: inout Contour, rhs: CGFloat) {
            lhs = lhs * rhs
        }
    }
}

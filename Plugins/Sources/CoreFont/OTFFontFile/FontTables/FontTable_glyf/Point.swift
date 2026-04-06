//
//  Point.swift
//  CoreFont
//
//  Created by Mark Douma on 4/4/2026.
//

import Foundation

extension FontTable_glyf {

    public struct Point: Copyable {
        public var point:       NSPoint

        public var x:           CGFloat {
            get { return point.x }
            set { point.x = newValue }
        }
        public var y:           CGFloat {
            get { return point.y }
            set { point.y = newValue }
        }

        public var flags:       Flags

        public var isOnCurve:     Bool {
            return flags.contains(Flags.onCurvePoint)
        }

        public init(point: NSPoint, flags: Flags) {
            self.point = point
            self.flags = flags
        }

        public mutating func translate(x: CGFloat, y: CGFloat) {
            point.x += x
            point.y += y
        }

        public mutating func transform(using transform: AffineTransform) {
            point = transform.transform(point)
        }
    }
}

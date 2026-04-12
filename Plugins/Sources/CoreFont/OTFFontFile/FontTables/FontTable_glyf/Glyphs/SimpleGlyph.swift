//
//  SimpleGlyph.swift
//  CoreFont
//
//  Created by Mark Douma on 4/3/2026.
//

import Cocoa
import RFSupport

extension FontTable_glyf {

    public final class SimpleGlyph: Glyph {
        // public var endPointIndexes:              [UInt16] = []   /// indexes of last points of contour in all contours
        public var endPointIndexes:                 IndexSet!       /// [UInt16] indexes of last points of contour in all contours

        public var instructionsLength:              UInt16   = 0
        public var instructions:                    Data?

        public var flags:                           [Flags] = []
        public var xCoordinates:                    [Int] = []
        public var yCoordinates:                    [Int] = []

        public override var bezierPath: NSBezierPath? {
            guard let contours = coordinates?.contours else { return nil }
            return Contour.bezierPathRepresentation(of: contours, glyph: self)
        }

        private var dropsImpliedOnCurvePoints:      Bool = false

        public required init(_ reader: BinaryDataReader, location: FontTable_loca.GlyphLocation, glyphID: GlyphID, table: FontTable_glyf) throws {
            try super.init(reader, location: location, glyphID: glyphID, table: table)
            assert(numberOfContours > 0)
            let indexes: [UInt16] = try (0..<numberOfContours).map { _ in try reader.read() }
            endPointIndexes = IndexSet(indexes.map { Int($0) })
            instructionsLength = try reader.read()
            if instructionsLength > 0 {
                instructions = try reader.readData(length: Int(instructionsLength))
            }
            /// read flags
            let numPoints = endPointIndexes.last! + 1
            var i = 0
            while i < numPoints {
                let flag: Flags = try reader.read()
                flags.append(flag)
                if flag.contains(.repeat) {
                    let repeatCount: UInt8 = try reader.read()
                    var repeatCnt = Int(repeatCount)
                    while repeatCnt > 0 {
                        flags.append(flag)
                        repeatCnt -= 1
                        i += 1
                    }
                }
                i += 1
            }
            /// read x-coordinates
            var coord = 0; i = 0
            while i < numPoints {
                let flag = flags[i]
                if flag.contains(.shortX) {
                    let value: UInt8 = try reader.read()
                    coord += (flag.contains(.shortXIsPosOrNextXIsSame) ? Int(value) : -Int(value) )
                } else if !flag.contains(.shortXIsPosOrNextXIsSame) {
                    let value: Int16 = try reader.read()
                    coord += Int(value)
                }
                xCoordinates.append(coord)
                i += 1
            }
            coord = 0; i = 0
            /// read y-coordinates
            while i < numPoints {
                let flag = flags[i]
                if flag.contains(.shortY) {
                    let value: UInt8 = try reader.read()
                    coord += (flag.contains(.shortYIsPosOrNextYIsSame) ? Int(value) : -Int(value) )
                } else if !flag.contains(.shortYIsPosOrNextYIsSame) {
                    let value: Int16 = try reader.read()
                    coord += Int(value)
                }
                yCoordinates.append(coord)
                i += 1
            }
            guard xCoordinates.count == yCoordinates.count else { throw FontTableError.parseError("xCoordinates.count != yCoordinates.count") }
            coordinates = try Coordinates(xCoordinates: xCoordinates, yCoordinates: yCoordinates, endPointIndexes: endPointIndexes, flags: flags, numPoints: flags.count, type: .absolute, glyph: self, table: table)
        }
    }
}

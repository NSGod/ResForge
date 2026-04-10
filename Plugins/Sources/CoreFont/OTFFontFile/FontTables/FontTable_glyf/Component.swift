//
//  Component.swift
//  CoreFont
//
//  Created by Mark Douma on 4/4/2026.
//
///  Based in part on code from
///  https://github.com/fonttools/fonttools/blob/main/Lib/fontTools/ttLib/tables/_g_l_y_f.py
///  MIT License
///
///  Copyright (c) 2017 Just van Rossum
///
///  Permission is hereby granted, free of charge, to any person obtaining a copy
///  of this software and associated documentation files (the "Software"), to deal
///  in the Software without restriction, including without limitation the rights
///  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
///  copies of the Software, and to permit persons to whom the Software is
///  furnished to do so, subject to the following conditions:
///
///  The above copyright notice and this permission notice shall be included in all
///  copies or substantial portions of the Software.
///
///  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
///  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
///  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
///  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
///  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
///  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
///  SOFTWARE.

import Cocoa
import RFSupport

extension FontTable_glyf {

    public final class Component: FontTableNode, FontAwaking {
        public struct Flags: OptionSet {
            public let rawValue: UInt16

            public static let none:                     Flags = []
            public static let argsAre16Bit:        Flags = .init(rawValue: 1 << 0)  /// (1, 0x01) if set, they're 16-bit, otherwise 8-bit
            public static let argsAreXYValues:          Flags = .init(rawValue: 1 << 1)  /// (2, 0x02) if set, arguments are xy values, otherwise they're points
            public static let roundXYToGrid:            Flags = .init(rawValue: 1 << 2)  /// (4, 0x04) if set, round xy values to grid, otherwise don't
                                                                                         ///   (only relevant if `.argsAreXYValues` is set)
            public static let weHaveAScale:             Flags = .init(rawValue: 1 << 3)  /// (8, 0x08) if set, there's a simple scale for the component, otherwise,
                                                                                         ///    scale is 1.0
            public static let nonOverlapping:           Flags = .init(rawValue: 1 << 4)  /// (16, 0x10) obsolete; set to 0
            public static let moreComponents:           Flags = .init(rawValue: 1 << 5)  /// (32, 0x20) if set, at least one additional glyph follows this one
            public static let weHaveAnXAndYScale:       Flags = .init(rawValue: 1 << 6)  /// (64, 0x40) if set, transform will scale x differently than y
            public static let weHaveA2x2:               Flags = .init(rawValue: 1 << 7)  /// (128, 0x80) if set, there's a 2x2 transform used to scale component
            public static let weHaveInstructions:       Flags = .init(rawValue: 1 << 8)  /// (256, 0x100) if set, instructions for component char follow last component
            public static let useMyMetrics:             Flags = .init(rawValue: 1 << 9)  /// (512, 0x200) use metrics from this component for the compound glyph
            public static let overlapCompound:          Flags = .init(rawValue: 1 << 10) /// (1024, 0x400) if set, components in this compound glyph overlap
            public static let scaledComponentOffset:    Flags = .init(rawValue: 1 << 11) /// (2048, 0x800) Composite designed to have component offset scaled
                                                                                         ///     (designed for Apple)
            public static let unscaledComponentOffset:  Flags = .init(rawValue: 1 << 12) /// (4096, 0x1000) Composite designed to NOT have component offset scaled
                                                                                         ///     (designed for MS)
            /// bits 4, 13, 14, & 15 are reserved; set to 0

            /// The Apple and MS rasterizers behave differently for
            /// scaled composite components: one does scale first and then translate
            /// and the other does it vice versa. MS defined some flags to indicate
            /// the difference, but it seems nobody actually _sets_ those flags.
            ///
            /// Funny thing: Apple seems to only do their thing in the
            /// `.weHaveAScale` (eg. Chicago) case, and not when it's `.weHaveAnXAndYScale`
            /// (eg. Charcoal)...
            ///
            public static let scaleComponentOffsetDefault: Bool = false /// false == MS, true == Apple

            public init(rawValue: UInt16) {
                self.rawValue = rawValue
            }
        }

        // MARK: -
        public var flags:                   Flags = .none
        public var glyphID:                 GlyphID = 0
        public var arg1:                    Int16 = 0
        public var arg2:                    Int16 = 0

        public var fDotTransform:           [[Fixed2Dot14]] ///  fDotTransform[2][2]
        public var instructionsLength:      UInt16 = 0
        public var instructions:            Data?

        // MARK: AUX:
        public var transform:               AffineTransform = .identity
        public var pointMatchingTransform:  AffineTransform?    /// for compound points

        public var bezierPath:              NSBezierPath?

        public var coordinates:             Coordinates!
        
        /// parent glyph:
        public weak var compoundGlyph:      CompoundGlyph!

        /// referenced glyph; this could be a simple or compound glyph
        public weak var glyph:         Glyph? {
            return (table as! FontTable_glyf).glyph(for: glyphID)
        }


        public init(_ reader: BinaryDataReader, compoundGlyph: CompoundGlyph, table: FontTable_glyf) throws {
            self.compoundGlyph = compoundGlyph
            fDotTransform = Array(repeating: Array(repeating: 0, count: 2), count: 2)
            try super.init(reader, table: table)
            flags = try reader.read()
            glyphID = try reader.read()
            if flags.contains(.argsAre16Bit) {
                /// short word arguments
                arg1 = try reader.read()
                arg2 = try reader.read()
            } else {
                /// byte arguments
                if flags.contains(.argsAreXYValues) {
                    /// signed offsets
                    let byte1: Int8 = try reader.read()
                    let byte2: Int8 = try reader.read()
                    arg1 = Int16(byte1)
                    arg2 = Int16(byte2)
                } else {
                    /// unsigned anchor points
                    let byte1: UInt8 = try reader.read()
                    let byte2: UInt8 = try reader.read()
                    arg1 = Int16(byte1)
                    arg2 = Int16(byte2)
                }
            }
            if flags.contains(.weHaveAScale) {
                fDotTransform[0][0] = try reader.read()
                fDotTransform[1][0] = 0
                fDotTransform[0][1] = 0
                fDotTransform[1][1] = fDotTransform[0][0]
            } else if flags.contains(.weHaveAnXAndYScale) {
                fDotTransform[0][0] = try reader.read()
                fDotTransform[1][0] = 0
                fDotTransform[0][1] = 0
                fDotTransform[1][1] = try reader.read()
            } else if flags.contains(.weHaveA2x2) {
                fDotTransform[0][0] = try reader.read()
                fDotTransform[0][1] = try reader.read()
                fDotTransform[1][0] = try reader.read()
                fDotTransform[1][1] = try reader.read()
            } else {
                fDotTransform[0][0] = DoubleToFixed2Dot14(1.0)
                fDotTransform[0][1] = 0
                fDotTransform[1][0] = 0
                fDotTransform[1][1] = DoubleToFixed2Dot14(1.0)
            }
            if flags.contains(.argsAreXYValues) {
                /// component uses XY offsets
                if flags.contains([.weHaveAScale, .weHaveAnXAndYScale, .weHaveA2x2]) {
                    transform.m11 = Fixed2Dot14ToDouble(fDotTransform[0][0])
                    transform.m12 = Fixed2Dot14ToDouble(fDotTransform[0][1])
                    transform.m21 = Fixed2Dot14ToDouble(fDotTransform[1][0])
                    transform.m22 = Fixed2Dot14ToDouble(fDotTransform[1][1])
                    let appleWay = flags.contains(.scaledComponentOffset)
                    let msWay = flags.contains(.unscaledComponentOffset)
                    if appleWay && msWay {
                        NSLog("\(type(of: self)).\(#function) *** ERROR: cannot have both scaled component offset and unscaled component offset flags")
                        throw FontTableError.parseError("both scaled and unscaled component offset flags")
                    }
                    var scaleComponentOffset = false
                    if !(appleWay || msWay) {
                        scaleComponentOffset = Flags.scaleComponentOffsetDefault
                    } else {
                        scaleComponentOffset = appleWay
                    }
                    if scaleComponentOffset {
                        /// The Apple way: first move, then scale (i.e. scale the component offset)
                        transform.prepend(AffineTransform(translationByX: CGFloat(arg1), byY: CGFloat(arg2)))
                    } else {
                        /// The MS way: first scale, then move
                        /// already scaled, just do the translate
                        transform.translate(x: CGFloat(arg1), y: CGFloat(arg2))
                    }
                } else {
                    transform.translate(x: CGFloat(arg1), y: CGFloat(arg2))
                }
            } else {
                NSLog("\(type(of: self)).\(#function) *** NOTICE: compound point for \(String(describing: table.fontGlyphName(for: glyphID))): {\(arg1), \(arg2)}")
            }
            if flags.contains(.weHaveInstructions) {
                instructionsLength = try reader.read()
                instructions = try reader.readData(length: Int(instructionsLength))
            }

        }

        public static func components(_ reader: BinaryDataReader, compoundGlyph: CompoundGlyph, table: FontTable_glyf) throws -> [Component] {
            guard let maxpTable = table.maxpTable else { throw FontTableError.parseError("missing maxp table") }
            let maxComponents = Int(maxpTable.maxComponentElements)
            var mComponents = [Component]()
            var i = 0
            while true {
                if i >= maxComponents {
                    /// exceeded max component count
                    NSLog("\(type(of: self)).\(#function) *** ERROR: exceeded max component count of \(maxComponents)")
                    break
                }
                let component = try Component(reader, compoundGlyph: compoundGlyph, table: table)
                mComponents.append(component)
                if !component.flags.contains(.moreComponents) { break }
                i += 1
            }
            return mComponents
        }

        @available(*, unavailable, message: "use `init(_:location:glyphID:table:)")
        public override init(_ reader: BinaryDataReader? = nil, offset: Int? = nil, table: FontTable) throws {
            fatalError("use `init(_:location:glyphID:table:)")
        }

        public func awakeFromFont() {
            /// compound glyph calls our variation below
        }

        /// NOTE: component doesn't alter coordinates, it uses them for component point matching to derive pointMatchingTransform
        public func awakeFromFont(with coordinates: Coordinates?) {
            if !flags.contains(.argsAreXYValues) {
                /// Component uses two reference points: we apply the transform _before_ computing
                /// the offset between points.
                var p1 = 0 /// Compound matching point index
                var p2 = 0 /// Component matching point index
                if flags.contains(.argsAre16Bit) {
                    // p1 = (UInt16)arg1
                    // p2 = (UInt16)arg2
                    p1 = Int(arg1)
                    p2 = Int(arg2)
                } else {
                    p1 = Int(arg1)
                    p2 = Int(arg2)
                }
                guard let glyphCoords = glyph?.coordinates else {
                    NSLog("\(type(of: self)).\(#function) *** ERROR: no coordinates for glyph \(String(describing: glyph?.glyphID))")
                    return
                }
                self.coordinates = glyphCoords
                self.coordinates.transform(using: transform)
                bezierPath = glyph?.bezierPath?.copy() as? NSBezierPath
                bezierPath?.transform(using: transform)
                if let coordinates {
                    if p1 > coordinates.numPoints {
                        // FIXME: !! log error
                    }
                    if p2 > self.coordinates.numPoints {
                        // FIXME: !! log error
                    }
                    let point1 = coordinates.points[p1]
                    let point2 = self.coordinates.points[p2]
                    // FIXME: get rid of single-point contours used for compound point-matching?
                    /// add the compount point matching as a translate transform to the existing transform
                    pointMatchingTransform = .init(translationByX: point1.x - point2.x, byY: point1.y - point2.y)
                    self.coordinates.transform(using: pointMatchingTransform!)
                    bezierPath?.transform(using: pointMatchingTransform!)
                }
            }
        }
    }
}

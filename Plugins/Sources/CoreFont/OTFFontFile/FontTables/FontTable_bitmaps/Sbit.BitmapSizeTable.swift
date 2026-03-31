//
//  Sbit.BitmapSizeTable.swift
//  CoreFont
//
//  Created by Mark Douma on 3/31/2026.
//

import Foundation
import RFSupport

extension Sbit {

    /// in `bloc` table
    public class BitmapSizeTable: Node, Comparable {

        public struct Flags: OptionSet {
            public let rawValue: UInt8

            public init(rawValue: UInt8) {
                self.rawValue = rawValue
            }

            public static let horizontal:   Flags = Flags(rawValue: 1 << 0) // small metrics are horizontal
            public static let vertical:     Flags = Flags(rawValue: 1 << 1) // small metrics are vertical
        }

        @objc public enum BitDepth: UInt8 {
            case oneBit     = 1     // black/white
            case twoBit     = 2     // 4 levels of gray
            case fourBit    = 4     // 16 levels of gray
            case eightBit   = 8     // 256 levels of gray
        }

        // MARK: -
        public var indexSubTableArrayOffset:    UInt32 = 0          /// Offset to corresponding index subtable array from the beginning of the `bloc`.
        public var indexTableSize:              UInt32 = 0          /// Length of corresponding index subtables and array
        public var numberOfIndexSubTables:      UInt32 = 0          /// Number of index subtables (there is one for each range or format change).
        public var colorRef:                    UInt32 = 0          /// not used by Apple
        public var hori:                        LineMetrics    /// horizontal line metrics
        public var vert:                        LineMetrics    /// vertical line metrics
        public var startGlyphIndex:             GlyphID = 0         /// lowest glyph index for this size
        public var endGlyphIndex:               GlyphID = 0         /// highest glyph index for this size
        public var ppemX:                       UInt8 = 0           /// target horizontal pixels-per-em
        public var ppemY:                       UInt8 = 0           /// target vertical pixels-per-em
        public var bitDepth:                    BitDepth = .oneBit  /// bit depth of the strike
        public var flags:                       Flags = []

        public var indexSubtableArray:          IndexSubtableArray

        public override var nodeLength: UInt32 {
            return Self.nodeLength + indexSubtableArray.nodeLength
        }

        public override class var nodeLength: UInt32 {
            return UInt32(16 + Sbit.LineMetrics.nodeLength * 2 + 4 + 4)  // 48
        }

        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            assert(offset == nil)
            indexSubTableArrayOffset = try reader.read()
            indexTableSize = try reader.read()
            numberOfIndexSubTables = try reader.read()
            colorRef = try reader.read()
            hori = try Sbit.LineMetrics(reader)
            vert = try Sbit.LineMetrics(reader)
            startGlyphIndex = try reader.read()
            endGlyphIndex = try reader.read()
            ppemX = try reader.read()
            ppemY = try reader.read()
            bitDepth = try reader.read()
            flags = Flags(rawValue: try reader.read())
            indexSubtableArray = try IndexSubtableArray(reader, offset: Int(indexSubTableArrayOffset))
            try super.init(reader, offset: offset)
        }

        /// says "Sizes must be sorted in ascending order" but not sure what that means
        public static func < (lhs: BitmapSizeTable, rhs: BitmapSizeTable) -> Bool {
            if lhs.ppemX != rhs.ppemX { return lhs.ppemX < rhs.ppemX }
            if lhs.ppemY != rhs.ppemY { return lhs.ppemY < rhs.ppemY }
            if lhs.startGlyphIndex != rhs.startGlyphIndex { return lhs.startGlyphIndex < rhs.startGlyphIndex }
            return lhs.endGlyphIndex < rhs.endGlyphIndex
        }

        public static func == (lhs: BitmapSizeTable, rhs: BitmapSizeTable) -> Bool {
            return lhs.ppemX == rhs.ppemX && lhs.ppemY == rhs.ppemY
        }
    }
}

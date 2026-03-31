//
//  Sbit.BitmapSizeTable.swift
//  CoreFont
//
//  Created by Mark Douma on 3/31/2026.
//

import Foundation
import RFSupport

extension Sbit {

    /// in `bloc`/`EBLC` table
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
        public var indexSubTableArrayOffset:    UInt32              /// Offset to corresponding index subtable array from the beginning of the `bloc`.
        public var indexTableSize:              UInt32              /// Length of corresponding index subtables and array
        public var numberOfIndexSubTables:      UInt32              /// Number of index subtables (there is one for each range or format change).
        public var colorRef:                    UInt32              /// not used by Apple
        public var hori:                        LineMetrics         /// horizontal line metrics
        public var vert:                        LineMetrics         /// vertical line metrics
        public var startGlyphIndex:             GlyphID             /// lowest glyph index for this size
        public var endGlyphIndex:               GlyphID             /// highest glyph index for this size
        public var ppemX:                       UInt8               /// target horizontal pixels-per-em
        public var ppemY:                       UInt8               /// target vertical pixels-per-em
        public var bitDepth:                    BitDepth            /// bit depth of the strike
        public var flags:                       Flags

        /* The BitmapSize table for each strike contains the offset to an array of IndexSubTableArray elements. Each
         element describes a glyph ID range and an offset to the IndexSubTable for that range. This allows a strike to
         contain multiple glyph ID ranges and to be represented in multiple index formats if desirable. */
        public var indexSubtableArrays:         [IndexSubtableArray]

        public override var nodeLength: UInt32 {
            return Self.nodeLength + indexSubtableArrays.map(\.nodeLength).reduce(0, +)
        }

        public override class var nodeLength: UInt32 {
            return UInt32(16 + LineMetrics.nodeLength * 2 + 4 + 4)  // 48
        }

        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            assert(offset == nil)
            indexSubTableArrayOffset = try reader.read()
            indexTableSize = try reader.read()
            numberOfIndexSubTables = try reader.read()
            colorRef = try reader.read()
            hori = try LineMetrics(reader)
            vert = try LineMetrics(reader)
            startGlyphIndex = try reader.read()
            endGlyphIndex = try reader.read()
            ppemX = try reader.read()
            ppemY = try reader.read()
            bitDepth = try reader.read()
            flags = Flags(rawValue: try reader.read())
            let off = Int(indexSubTableArrayOffset)
            reader.pushSavedPosition()
            try reader.setPosition(off)
            defer { reader.popPosition() }
            indexSubtableArrays = try (0..<numberOfIndexSubTables).map { _ in try IndexSubtableArray(reader, offset: off) }
            try super.init(reader, offset: off)
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

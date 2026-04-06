//
//  Component.swift
//  CoreFont
//
//  Created by Mark Douma on 4/4/2026.
//

import Cocoa

extension FontTable_glyf {

    public final class Component: FontTableNode, FontAwaking {
        public struct Flags: OptionSet {
            public let rawValue: UInt16

            public static let none:                     Flags = []
            public static let args1And2Are16Bit:        Flags = .init(rawValue: 1 << 0)  /// (1, 0x01) if set, they're 16-bit, otherwise 8-bit
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

            public init(rawValue: UInt16) {
                self.rawValue = rawValue
            }

        }

        // MARK: -
        public var flags:                   Flags = .none
        public var glyphID:                 GlyphID = 0
        public var arg1:                    Int16 = 0
        public var arg2:                    Int16 = 0

        public var fDotTransform:           [Fixed2Dot14] = [] ///  fDotTransform[2][2]

        public var instructionsLength:      UInt16 = 0
        public var instructions:            Data?

        // MARK: AUX:
        public var transform:               AffineTransform = .identity
        public var pointMatchingTransform:  AffineTransform?    /// for compound points

        public var bezierPath:              NSBezierPath?

        /// parent glyph:
        public weak var compoundGlyph:      CompoundGlyph?

        /// this could be a simple or compound glyph
        public weak var glyph:              Glyph?


        public init
        public func awakeFromFont() {

        }


    }
}

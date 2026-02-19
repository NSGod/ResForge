//
//  KernTable.swift
//  CoreFont
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=494

import Foundation
import RFSupport

extension FOND {

    final public class KernTable: FONDResourceNode {
        public var numberOfEntries:             Int16              // number of entries - 1
        public var entries:                     [Entry]

        public var hasOutOfRangeCharCodes:      Bool = false
        private var fontStylesToEntries:        [MacFontStyle: Entry]

        @objc public override var totalNodeLength: Int {
            return MemoryLayout<Int16>.size + entries.reduce(0) { $0 + $1.totalNodeLength }
        }

        public init(_ reader: BinaryDataReader, fond: FOND) throws {
            numberOfEntries = try reader.read()
            entries = []
            fontStylesToEntries = [:]
            for _ in 0...numberOfEntries {
                let entry = try Entry(reader, fond: fond)
                entries.append(entry)
                fontStylesToEntries[entry.style] = entry
                hasOutOfRangeCharCodes = hasOutOfRangeCharCodes ? true : entry.hasOutOfRangeCharCodes
            }
            super.init(fond:fond)
        }

        public override func write(to dataHandle: DataHandle) throws {
            numberOfEntries = Int16(entries.count - 1)
            dataHandle.write(numberOfEntries)
            try entries.forEach { try $0.write(to: dataHandle) }
        }

        public func entry(for fontStyle: MacFontStyle) -> Entry? {
            return fontStylesToEntries[fontStyle]
        }
    }
}

// MARK: -
extension FOND.KernTable {

    final public class Entry: FONDResourceNode {
        public var style:              MacFontStyle            // style this entry applies to

        /// NOTE: While `numKerns` is defined as a `SInt16`, it makes no sense to have negative kern pairs,
        ///       and I *have* encountered fonts that have more than 32,767 kern pairs, so make it an `UInt16`
        ///
        public var numKerns:           UInt16  /// Number of kern pairs that follow (and NOT the entryLength/length
                                               /// of the data that follows this struct as is documented in IM).

        public var kernPairs:          [KernPair]

        // MARK: AUX
        public var hasOutOfRangeCharCodes: Bool = false

        // needed for display:
        @objc public var objcStyle:    MacFontStyle.RawValue {
            didSet { style = .init(rawValue: objcStyle) }
        }

        @objc public override var totalNodeLength:    Int {
            return MemoryLayout<UInt16>.size * 2 + Int(numKerns) * KernPair.nodeLength
        }

        public init(_ reader: BinaryDataReader, fond: FOND) throws {
            style = try reader.read()
            objcStyle = style.rawValue
            numKerns = try reader.read()
            kernPairs = []
            for _ in 0..<numKerns {
                let kernPair: KernPair = try KernPair(reader)
                kernPairs.append(kernPair)
                hasOutOfRangeCharCodes = hasOutOfRangeCharCodes ? true : kernPair.hasOutOfRangeCharCodes
            }
            super.init(fond: fond)
        }

        public override func write(to dataHandle: DataHandle) throws {
            numKerns = UInt16(kernPairs.count)
            dataHandle.write(style)
            dataHandle.write(numKerns)
            try kernPairs.forEach { try $0.write(to: dataHandle) }
        }
    }
}

extension FOND.KernTable {

    public struct KernPair {
        public var kernFirst:  UInt8           // 1st character of kerned pair
        public var kernSecond: UInt8           // 2nd character of kerned pair
        public var kernWidth:  Fixed4Dot12     // kerning distance, in pixels, for the 2 glyphs at size of 1pt; fixed-point 4.12 format

        public static var nodeLength: Int {
            return MemoryLayout<UInt8>.size * 2 + MemoryLayout<Fixed4Dot12>.size // 4
        }

        public init(_ reader: BinaryDataReader) throws {
            kernFirst = try reader.read()
            kernSecond = try reader.read()
            kernWidth = try reader.read()
        }

        public func write(to dataHandle: DataHandle) throws {
            dataHandle.write(kernFirst)
            dataHandle.write(kernSecond)
            dataHandle.write(kernWidth)
        }

        public var hasOutOfRangeCharCodes: Bool {
            // FIXME: this is no longer true for the "enhanced/expanded" macRomanEncoding?
            return kernFirst < 0x20 || kernSecond < 0x20 || kernFirst == 0x7F || kernSecond == 0x7F
        }

        /// bare-bones `description` that doesn't try to resolve glyph names or factor in unitsPerEm
        public var description: String {
            return "\(kernFirst), \(kernSecond), \(Fixed4Dot12ToDouble(kernWidth))"
        }

        public static func == (lhs: FOND.KernTable.KernPair, rhs: FOND.KernTable.KernPair) -> Bool {
            return lhs.kernFirst == rhs.kernFirst && lhs.kernSecond == rhs.kernSecond && lhs.kernWidth == rhs.kernWidth
        }
    }
}

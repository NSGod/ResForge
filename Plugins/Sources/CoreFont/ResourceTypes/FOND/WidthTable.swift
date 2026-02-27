//
//  WidthTable.swift
//  CoreFont
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=486

import Foundation
import RFSupport

extension FOND {

    final public class WidthTable: FONDResourceNode {
        public var numberOfEntries:    Int16               // number of entries - 1
        public var entries:            [Entry]

        public override var totalNodeLength: Int {
            return MemoryLayout<Int16>.size + entries.reduce(0) { $0 + $1.totalNodeLength }
        }

        public init(_ reader: BinaryDataReader, fond: FOND) throws {
            numberOfEntries = try reader.read()
            entries = try (0...numberOfEntries).map { _ in try Entry(reader, fond:fond) }
            super.init(fond:fond)
        }

        public override func write(to dataHandle: DataHandle) throws {
            numberOfEntries = Int16(entries.count - 1)
            dataHandle.write(numberOfEntries)
            try entries.forEach { try $0.write(to: dataHandle) }
        }
    }
}

extension FOND.WidthTable {

    final public class Entry: FONDResourceNode {
        public var style:              MacFontStyle        // style entry applies to
        @objc public var widths:       [Fixed4Dot12]

        /// needed for display:
        @objc public var objcStyle:    MacFontStyle.RawValue {
            didSet { style = .init(rawValue: self.objcStyle) }
        }

        public override var totalNodeLength: Int {
            return MemoryLayout<MacFontStyle.RawValue>.size + widths.count * MemoryLayout<Fixed4Dot12>.size
        }

        public init(_ reader: BinaryDataReader, fond: FOND) throws {
            style = try reader.read()
            objcStyle = style.rawValue
            /// I'm not exactly sure why this is + 3, but that's what FontForge does
            /// https://github.com/fontforge/fontforge/blob/7195402701ace7783753ef9424153eff48c9af44/fontforge/macbinary.c#L2342
            /// this is why we neeed to be a FONDResourceNode w/ access to the FOND:
            /// So additional info on where this 258 character count comes from: I first saw code
            /// that alluded to this in FontForge:
            /// https://github.com/fontforge/fontforge/blob/7195402701ace7783753ef9424153eff48c9af44/fontforge/macbinary.c#L2342
            /// The documentation in Inside Macintosh: Text, regarding this stuff is, at least IMO, not the
            /// clearest. When viewing an `NFNT` in Resorcerer that has a standard 0...255 range,
            /// it also shows 258 entries, indexed 0...257. First, there's the standard 255. Following that, there's
            /// the missing glyph entry, which is usually a rectangular box — w/ or w/o an X through it —
            /// to be used for any char codes that don't have an actual bitmap glyph image. Following that is
            /// a sentinel final glyph entry that has a -1 offset and width.
            let numGlyphs = fond.lastChar - fond.firstChar + 3
            widths = try (0..<numGlyphs).map { _ in try reader.read() }
            super.init(fond: fond)
        }

        public override func write(to dataHandle: DataHandle) throws {
            dataHandle.write(style)
            widths.forEach { dataHandle.write($0) }
        }
    }
}

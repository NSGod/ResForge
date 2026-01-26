//
//  WidthTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=486

import Foundation
import RFSupport
import CoreFont

final public class WidthTable: FONDResourceNode {
    public var numberOfEntries:    Int16               // number of entries - 1
    public var entries:            [Entry]

    public override var length: Int {
        var length = MemoryLayout<Int16>.size
        for entry in self.entries { length += entry.length }
        return length
    }

    public init(_ reader: BinaryDataReader, fond: FOND) throws {
        numberOfEntries = try reader.read()
        entries = []
        for _ in 0...numberOfEntries {
            let entry = try Entry(reader, fond:fond)
            entries.append(entry)
        }
        super.init(fond:fond)
    }
}

extension WidthTable {

    final public class Entry: FONDResourceNode {
        public var style:              MacFontStyle        // style entry applies to
        @objc public var widths:       [Fixed4Dot12]

        @objc public var objcStyle:    MacFontStyle.RawValue {
            didSet { style = .init(rawValue: self.objcStyle) }
        }
        public override var length: Int {
            return MemoryLayout<MacFontStyle.RawValue>.size + widths.count * MemoryLayout<Fixed4Dot12>.size
        }

        public init(_ reader: BinaryDataReader, fond: FOND) throws {
            style = try reader.read()
            objcStyle = style.rawValue
            widths = []
            // I'm not exactly sure why this is + 3, but that's what FontForge does
            // https://github.com/fontforge/fontforge/blob/7195402701ace7783753ef9424153eff48c9af44/fontforge/macbinary.c#L2342
            // this is why we neeed to be a FONDResourceNode w/ access to the FOND:
            let numGlyphs = fond.lastChar - fond.firstChar + 3
            for _ in 0..<numGlyphs {
                let width: Fixed4Dot12 = try reader.read()
                widths.append(width)
            }
            super.init(fond: fond)
        }
    }
}

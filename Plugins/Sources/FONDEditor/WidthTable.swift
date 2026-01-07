//
//  WidthTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=486

import Foundation
import RFSupport

// will be displayed in UI, so need NSObject subclass?

final class WidthTable: FONDResourceNode {
    var numberOfEntries:    Int16               // number of entries - 1
    var entries:            [WidthTableEntry]

    override var length: Int {
        get {
            var length = MemoryLayout<Int16>.size
            for entry in self.entries { length += entry.length }
            return length
        }
        set {}
    }

    init(_ reader: BinaryDataReader, fond: FOND) throws {
        numberOfEntries = try reader.read()
        entries = []
        for _ in 0...numberOfEntries {
            let entry = try WidthTableEntry(reader, fond:fond)
            entries.append(entry)
        }
        super.init(fond:fond)
    }
}


final class WidthTableEntry: FONDResourceNode {
    var style:              MacFontStyle        // style entry applies to
    var widths:             [Fixed4Dot12]

    override var length: Int {
        get { return MemoryLayout<MacFontStyle>.size + widths.count * MemoryLayout<Fixed4Dot12>.size }
        set {}
    }

    init(_ reader: BinaryDataReader, fond: FOND) throws {
        style = try reader.read()
        widths = []
        // I'm not exactly sure why this is + 3, but that's what FontForge does
        let numGlyphs = fond.lastChar - fond.firstChar + 3
        for _ in 0..<numGlyphs {
            let width: Fixed4Dot12 = try reader.read()
            widths.append(width)
        }
        super.init(fond: fond)
    }
}

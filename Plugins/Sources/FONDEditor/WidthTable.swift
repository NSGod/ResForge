//
//  WidthTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=486

import Cocoa
import RFSupport

struct WidthTable {
    var numberOfEntries:    Int16               // number of entries - 1
    var entries:            [WidthTableEntry]
}

extension WidthTable {
    var length: Int {
        var length = MemoryLayout<Int16>.size
        for entry in self.entries { length += entry.length }
        return length
    }
    
    init(_ reader: BinaryDataReader, fond parentFond: FOND) throws {
        numberOfEntries = try reader.read()
        entries = []
        for _ in 0...numberOfEntries {
            let entry = try WidthTableEntry(reader, fond:parentFond)
            entries.append(entry)
        }
    }
}


struct WidthTableEntry {
    var style:              MacFontStyle        // style entry applies to
    var widths:             [Fixed4Dot12]
}

extension WidthTableEntry {
    var length: Int {
        return MemoryLayout<MacFontStyle>.size + widths.count * MemoryLayout<Fixed4Dot12>.size //
    }

    init(_ reader: BinaryDataReader, fond parentFond: FOND) throws {
        style = try reader.read()
        widths = []
        // I'm not exactly sure why this is + 3, but that's what FontForge does
        let numGlyphs = parentFond.lastChar - parentFond.firstChar + 3
        for _ in 0..<numGlyphs {
            let width: Fixed4Dot12 = try reader.read()
            widths.append(width)
        }
    }
}

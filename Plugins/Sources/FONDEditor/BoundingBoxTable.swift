//
//  BoundingBoxTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=485

import Cocoa
import RFSupport

struct BoundingBoxTable {
    var numberOfEntries:    Int16                      // number of entries - 1
    var entries:            [BoundingBoxTableEntry]
}

extension BoundingBoxTable {
    init(_ reader: BinaryDataReader) throws {
        numberOfEntries = try reader.read()
        entries = []
        for _ in 0...numberOfEntries {
            let entry = try BoundingBoxTableEntry(reader)
            entries.append(entry)
        }
    }
}


struct BoundingBoxTableEntry {
    var fontStyle:  MacFontStyle
    var left:       Fixed4Dot12
    var bottom:     Fixed4Dot12
    var right:      Fixed4Dot12
    var top:        Fixed4Dot12
}

extension BoundingBoxTableEntry {
    init(_ reader: BinaryDataReader) throws {
        fontStyle = try reader.read()
        left = try reader.read()
        bottom = try reader.read()
        right = try reader.read()
        top = try reader.read()
    }
}

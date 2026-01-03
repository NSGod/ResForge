//
//  BoundingBoxTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=485

import Foundation
import RFSupport

// will be displayed in UI, so need NSObject subclass?

final class BoundingBoxTable: ResourceNode {
    var numberOfEntries:    Int16                      // number of entries - 1
    var entries:            [BoundingBoxTableEntry]

    override var length:    Int {
        return MemoryLayout<Int16>.size + entries.count * BoundingBoxTableEntry.length
    }

    init(_ reader: BinaryDataReader) throws {
        numberOfEntries = try reader.read()
        entries = []
        for _ in 0...numberOfEntries {
            let entry = try BoundingBoxTableEntry(reader)
            entries.append(entry)
        }
        super.init()
    }
}


final class BoundingBoxTableEntry: ResourceNode {
    var fontStyle:  MacFontStyle
    var left:       Fixed4Dot12
    var bottom:     Fixed4Dot12
    var right:      Fixed4Dot12
    var top:        Fixed4Dot12

    override class var length: Int {
        return MemoryLayout<Int16>.size * 5 // 10
    }

    init(_ reader: BinaryDataReader) throws {
        fontStyle = try reader.read()
        left = try reader.read()
        bottom = try reader.read()
        right = try reader.read()
        top = try reader.read()
        super.init()
    }
}

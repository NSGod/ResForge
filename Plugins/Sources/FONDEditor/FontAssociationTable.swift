//
//  FontAssociationTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=483

import Foundation
import RFSupport

// will be displayed in UI, so need NSObject subclass?

final class FontAssociationTable: ResourceNode {
    var numberOfEntries:    Int16                           // number of entries - 1
    var entries:            [FontAssociationTableEntry]
    
    override var length: Int {
        return entries.count * FontAssociationTableEntry.length
    }

    init(_ reader: BinaryDataReader) throws {
        numberOfEntries = try reader.read()
        entries = []
        for _ in 0...numberOfEntries {
            let entry: FontAssociationTableEntry = try FontAssociationTableEntry(reader)
            entries.append(entry)
        }
        super.init()
    }
}


final class FontAssociationTableEntry: ResourceNode, Comparable {
    var fontPointSize:  Int16
    var fontStyle:      MacFontStyle
    var fontID:         ResID

    override class var length: Int {
        return MemoryLayout<Int16>.size + MemoryLayout<MacFontStyle>.size + MemoryLayout<ResID>.size // 6
    }

    init(_ reader: BinaryDataReader) throws {
        fontPointSize = try reader.read()
        fontStyle = try reader.read()
        fontID = try reader.read()
        super.init()
    }

    @objc func compare(_ otherEntry: FontAssociationTableEntry) -> ComparisonResult {
        if fontPointSize != otherEntry.fontPointSize {
            if fontPointSize < otherEntry.fontPointSize {
                return .orderedAscending
            } else {
                return .orderedDescending
            }
        } else {
            if fontStyle.rawValue < otherEntry.fontStyle.rawValue {
                return .orderedAscending
            } else if fontStyle.rawValue == otherEntry.fontStyle.rawValue {
                return .orderedSame
            } else {
                return .orderedDescending
            }
        }
    }

    static func < (lhs: FontAssociationTableEntry, rhs: FontAssociationTableEntry) -> Bool {
        if lhs.fontPointSize != rhs.fontPointSize {
            return lhs.fontPointSize < rhs.fontPointSize
        } else {
            return lhs.fontStyle < rhs.fontStyle
        }
    }
}

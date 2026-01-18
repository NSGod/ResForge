//
//  FontAssociationTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=483

import Foundation
import RFSupport
import CoreFont

final class FontAssociationTable: ResourceNode {
    var numberOfEntries:    Int16                           // number of entries - 1
    @objc var entries:      [FontAssociationTableEntry]

    override var length:    Int {
        get { return MemoryLayout<Int16>.size + entries.count * FontAssociationTableEntry.length }
        set {}
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

    func add(_ entry: FontAssociationTableEntry) throws {
        guard !entries.contains(entry) else {
            throw FONDError.fontAssociationTableEntriesRefSameFont
        }
        entries.append(entry)
        entries.sort(by: <)
        numberOfEntries = Int16(entries.count - 1)
    }

    func remove(_ entry: FontAssociationTableEntry) throws {
        guard entries.contains(entry) else {
            throw FONDError.noSuchFontAssociationTableEntry
        }
        entries.append(entry)
        entries.sort(by: <)
        numberOfEntries = Int16(entries.count - 1)
    }
}


final class FontAssociationTableEntry: ResourceNode, Comparable {
    @objc var fontPointSize:    Int16
    var fontStyle:              MacFontStyle
    @objc var fontID:           ResID

    @objc var objcFontStyle:    MacFontStyle.RawValue {
        didSet { fontStyle = .init(rawValue: objcFontStyle) }
    }

    override class var length: Int {
        return MemoryLayout<Int16>.size + MemoryLayout<MacFontStyle.RawValue>.size + MemoryLayout<ResID>.size // 6
    }

    init(_ reader: BinaryDataReader) throws {
        fontPointSize = try reader.read()
        fontStyle = try reader.read()
        fontID = try reader.read()
        objcFontStyle = fontStyle.rawValue
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

    static func == (lhs: FontAssociationTableEntry, rhs: FontAssociationTableEntry) -> Bool {
        return lhs.fontPointSize == rhs.fontPointSize &&
        lhs.fontStyle == rhs.fontStyle && lhs.fontID == rhs.fontID
    }
}

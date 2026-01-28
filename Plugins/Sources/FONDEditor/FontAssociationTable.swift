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

final public class FontAssociationTable: ResourceNode {
    public var numberOfEntries:    Int16                           // number of entries - 1
    @objc public var entries:      [Entry]

    @objc public override var length:    Int {
        return MemoryLayout<Int16>.size + entries.count * Entry.length
    }

    public init(_ reader: BinaryDataReader) throws {
        numberOfEntries = try reader.read()
        entries = try (0...numberOfEntries).map { _ in try Entry(reader) }
        super.init()
    }

    public func add(_ entry: Entry) throws {
        guard !entries.contains(entry) else {
            throw FONDError.fontAssociationTableEntriesRefSameFont
        }
        entries.append(entry)
        entries.sort(by: <)
        numberOfEntries = Int16(entries.count - 1)
    }

    public func remove(_ entry: Entry) throws {
        guard entries.contains(entry) else {
            throw FONDError.noSuchFontAssociationTableEntry
        }
        entries.append(entry)
        entries.sort(by: <)
        numberOfEntries = Int16(entries.count - 1)
    }
}

extension FontAssociationTable {
    final public class Entry: ResourceNode, Comparable {
        @objc public var fontPointSize:    Int16
        public var fontStyle:              MacFontStyle
        @objc public var fontID:           ResID

        @objc public var objcFontStyle:    MacFontStyle.RawValue {
            didSet { fontStyle = .init(rawValue: objcFontStyle) }
        }

        public override class var length: Int {
            return MemoryLayout<Int16>.size * 2 + MemoryLayout<MacFontStyle.RawValue>.size // 6
        }

        public init(_ reader: BinaryDataReader) throws {
            fontPointSize = try reader.read()
            fontStyle = try reader.read()
            fontID = try reader.read()
            objcFontStyle = fontStyle.rawValue
            super.init()
        }

        public static func < (lhs: Entry, rhs: Entry) -> Bool {
            if lhs.fontPointSize != rhs.fontPointSize {
                return lhs.fontPointSize < rhs.fontPointSize
            } else {
                return lhs.fontStyle < rhs.fontStyle
            }
        }

        public static func == (lhs: Entry, rhs: Entry) -> Bool {
            return lhs.fontPointSize == rhs.fontPointSize &&
            lhs.fontStyle == rhs.fontStyle && lhs.fontID == rhs.fontID
        }
    }
}

//
//  FontAssociationTable.swift
//  CoreFont
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=483

import Foundation
import RFSupport

extension FOND {

    public final class FontAssociationTable: ResourceNode {
        public var numberOfEntries:         Int16           // number of entries - 1
        @objc dynamic public var entries:   [Entry]

        @objc public override var totalNodeLength:    Int {
            return MemoryLayout<Int16>.size + entries.count * Entry.nodeLength
        }

        public init(_ reader: BinaryDataReader?, options: FontCreationOptions? = nil) throws {
            if let reader, !reader.data.isEmpty {
                numberOfEntries = try reader.read()
                entries = try (0..<numberOfEntries + 1).map { _ in try Entry(reader) }
            } else {
                numberOfEntries = 0
                entries = [try Entry(options: options)]
            }
            super.init()
        }

        public func sortEntries() {
            entries.sort(by: <)
        }

        public override func write(to handle: DataHandle, offset: Int? = nil) throws {
            assert(offset == nil)
            numberOfEntries = Int16(entries.count - 1)
            handle.write(numberOfEntries)
            try entries.forEach { try $0.write(to: handle) }
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
}

extension FOND.FontAssociationTable {

    public final class Entry: ResourceNode, Comparable {
        @objc dynamic public var fontPointSize:     Int16
        public var fontStyle:                       MacFontStyle
        @objc dynamic public var fontID:            ResID

        /// needed for display:
        @objc dynamic public var objcFontStyle:     UInt16 {
            get { return fontStyle.rawValue }
            set { fontStyle = .init(rawValue: newValue) }
        }

        @objc public override var nodeLength: Int {
            return Self.nodeLength
        }

        public override class var nodeLength: Int {
            return MemoryLayout<Int16>.size * 2 + MemoryLayout<MacFontStyle.RawValue>.size // 6
        }

        public init(_ reader: BinaryDataReader? = nil, options: FontCreationOptions? = nil, fontID: ResID? = nil) throws {
            if let reader, !reader.data.isEmpty {
                fontPointSize = try reader.read()
                fontStyle = try reader.read()
                self.fontID = try reader.read()
            } else {
                fontPointSize = 0
                fontStyle = options?.fontFile.macStyle ?? .regular
                self.fontID = fontID ?? options?.editorManager.uniqueResID(for: .sfnt) ?? ResID.random(in: 1024..<0x7FFF)
            }
            super.init()
        }

        public override func write(to handle: DataHandle, offset: Int? = nil) throws {
            assert(offset == nil)
            handle.write(fontPointSize)
            handle.write(fontStyle)
            handle.write(fontID)
        }

        public static func < (lhs: Entry, rhs: Entry) -> Bool {
            if lhs.fontPointSize != rhs.fontPointSize {
                return lhs.fontPointSize < rhs.fontPointSize
            } else {
                return lhs.fontStyle < rhs.fontStyle
            }
        }

        public override func isEqual(_ object: Any?) -> Bool {
            guard let other = object as? Entry else { return false }
            return fontPointSize == other.fontPointSize &&
            fontStyle == other.fontStyle && fontID == other.fontID
        }
    }
}

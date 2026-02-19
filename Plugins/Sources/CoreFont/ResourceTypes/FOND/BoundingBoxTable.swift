//
//  BoundingBoxTable.swift
//  CoreFont
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=485

import Foundation
import RFSupport

extension FOND {

    final public class BoundingBoxTable: ResourceNode {
        public var numberOfEntries:                 Int16           // number of entries - 1
        @objc public var entries:                   [Entry]

        @objc public override var totalNodeLength:  Int {
            return MemoryLayout<Int16>.size + entries.count * Entry.nodeLength
        }

        public init(_ reader: BinaryDataReader) throws {
            numberOfEntries = try reader.read()
            entries = try (0...numberOfEntries).map { _ in try Entry(reader) }
            super.init()
        }

        public override func write(to dataHandle: DataHandle) throws {
            numberOfEntries = Int16(entries.count - 1)
            dataHandle.write(numberOfEntries)
            try entries.forEach { try $0.write(to: dataHandle) }
        }
    }
}

extension FOND.BoundingBoxTable {

    final public class Entry: ResourceNode {
        public var style:              MacFontStyle
        @objc public var left:         Fixed4Dot12
        @objc public var bottom:       Fixed4Dot12
        @objc public var right:        Fixed4Dot12
        @objc public var top:          Fixed4Dot12

        /// needed for display:
        @objc var objcStyle:    MacFontStyle.RawValue {
            didSet { style = .init(rawValue: objcStyle) }
        }

        public override class var nodeLength: Int {
            return MemoryLayout<Int16>.size * 5 // 10
        }

        public init(_ reader: BinaryDataReader) throws {
            style = try reader.read()
            left = try reader.read()
            bottom = try reader.read()
            right = try reader.read()
            top = try reader.read()
            objcStyle = style.rawValue
            super.init()
        }

        public override func write(to dataHandle: DataHandle) throws {
            dataHandle.write(style)
            dataHandle.write(left)
            dataHandle.write(bottom)
            dataHandle.write(right)
            dataHandle.write(top)
        }
    }
}

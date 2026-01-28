//
//  BoundingBoxTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=485

import Foundation
import RFSupport
import CoreFont

final public class BoundingBoxTable: ResourceNode {
    public var numberOfEntries:         Int16           // number of entries - 1
    @objc public var entries:           [Entry]

    @objc public override var length:   Int {
        return MemoryLayout<Int16>.size + entries.count * Entry.length
    }

    public init(_ reader: BinaryDataReader) throws {
        numberOfEntries = try reader.read()
        entries = try (0...numberOfEntries).map { _ in try Entry(reader) }
        super.init()
    }
}

extension BoundingBoxTable {
    
    final public class Entry: ResourceNode {
        public var style:              MacFontStyle
        @objc public var left:         Fixed4Dot12
        @objc public var bottom:       Fixed4Dot12
        @objc public var right:        Fixed4Dot12
        @objc public var top:          Fixed4Dot12

        @objc var objcStyle:    MacFontStyle.RawValue {
            didSet { style = .init(rawValue: objcStyle) }
        }

        public override class var length: Int {
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
    }
}

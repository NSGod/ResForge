//
//  BoundingBoxTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=485

import Foundation
import RFSupport

final class BoundingBoxTable: ResourceNode {
    var numberOfEntries:    Int16                      // number of entries - 1
    @objc var entries:      [BoundingBoxTableEntry]

    @objc override var length:    Int {
        get { return MemoryLayout<Int16>.size + entries.count * BoundingBoxTableEntry.length }
        set {}
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
    var style:              MacFontStyle {
        didSet { objcStyle = style.rawValue }
    }

    var left:               Fixed4Dot12
    var bottom:             Fixed4Dot12
    var right:              Fixed4Dot12
    var top:                Fixed4Dot12

    @objc var objcStyle:    MacFontStyle.RawValue {
        didSet { style = .init(rawValue: objcStyle) }
    }

    override class var length: Int {
        return MemoryLayout<Int16>.size * 5 // 10
    }

    init(_ reader: BinaryDataReader) throws {
        style = try reader.read()
        left = try reader.read()
        bottom = try reader.read()
        right = try reader.read()
        top = try reader.read()
        objcStyle = style.rawValue
        super.init()
    }
}

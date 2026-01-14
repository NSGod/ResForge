//
//  FFsfntDirectory.swift
//  FontEditor
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport


class FFsfntDirectory: OTFFontFileNode {
    var format:                     FFsfntFormat            // 0x00010000, 'OTTO', 'true', etc.
    @objc var numberOfTables:       UInt16                  // number of tables
    @objc var searchRange:          UInt16                  // (max power of 2 <= numberOfTables) x 16
    @objc var entrySelector:        UInt16                  // log2(max power of 2 <= numberOfTables)
    @objc var rangeShift:           UInt16                  // numberOfTables * (16 - searchRange)

    @objc var entries:              [FFsfntDirectoryEntry]  // [numberOfTables]

    @objc var objcFormat:           FFsfntFormat.RawValue { format.rawValue }

    class var nodeLength: UInt32 {
        UInt32(MemoryLayout<UInt16>.size * 4 + MemoryLayout<FFsfntFormat.RawValue>.size) } // 12

    init(_ reader: BinaryDataReader) throws {
        format = FFsfntFormat(rawValue: try reader.read())
        numberOfTables = try reader.read()
        searchRange = try reader.read()
        entrySelector = try reader.read()
        rangeShift = try reader.read()
        entries = []
        for _ in 0..<Int(numberOfTables) {
            entries.append(try FFsfntDirectoryEntry(reader))
        }
        try super.init(fontFile: nil)
    }
}

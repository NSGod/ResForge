//
//  OTFsfntDirectory.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport

final public class OTFsfntDirectory: OTFFontFileNode, DataHandleWriting {
    public var format:                      OTFsfntFormat            // 0x00010000, 'OTTO', 'true', etc.
    @objc public var numberOfTables:        UInt16                   // number of tables
    @objc public var searchRange:           UInt16                   // (max power of 2 <= numberOfTables) x 16
    @objc public var entrySelector:         UInt16                   // log2(max power of 2 <= numberOfTables)
    @objc public var rangeShift:            UInt16                   // numberOfTables * (16 - searchRange)

    @objc public var entries:               [OTFsfntDirectoryEntry]  // [numberOfTables]

    @objc public var objcFormat:            OTFsfntFormat.RawValue { format.rawValue }

    public override var totalNodeLength:    UInt32 {
        numberOfTables = UInt16(entries.count)
        return Self.nodeLength + OTFsfntDirectoryEntry.nodeLength * UInt32(numberOfTables)
    }

    public class override var nodeLength:   UInt32 {
        UInt32(MemoryLayout<UInt16>.size * 4 + MemoryLayout<OTFsfntFormat.RawValue>.size) } // 12

    private var tableTagsToEntries: [TableTag: OTFsfntDirectoryEntry] = [:]

    public init(_ reader: BinaryDataReader, fontFile: OTFFontFile) throws {
        format = OTFsfntFormat(rawValue: try reader.read())
        numberOfTables = try reader.read()
        searchRange = try reader.read()
        entrySelector = try reader.read()
        rangeShift = try reader.read()
        entries = []
        for _ in 0..<numberOfTables {
            entries.append(try OTFsfntDirectoryEntry(reader, fontFile: fontFile))
            tableTagsToEntries[entries.last!.tableTag] = entries.last!
        }
        try super.init(fontFile: fontFile)
    }

    public func write(to dataHandle: DataHandle) throws {
        /// font calls sortEntries()
        calculateSearchParams()
        if format == .true {
            // change to .V1_0, which is more cross-platform/compatible
            format = .V1_0
        }
        dataHandle.write(format)
        dataHandle.write(numberOfTables)
        dataHandle.write(searchRange)
        dataHandle.write(entrySelector)
        dataHandle.write(rangeShift)
        try entries.forEach({ try $0.write(to: dataHandle) })
    }

    public func entry(for tableTag: TableTag) -> OTFsfntDirectoryEntry? {
        tableTagsToEntries[tableTag]
    }

    public func sortEntries() {
        entries.sort(by: <)
    }

    public func calculatedChecksum(with dataHandle: DataHandle) -> UInt32 {
        let data = dataHandle.data
        let subdata = data.subdata(in: data.startIndex..<data.startIndex + Int(totalNodeLength))
        let tableLongs: [UInt32] = subdata.withUnsafeBytes {
            $0.bindMemory(to: UInt32.self).map(\.bigEndian)
        }
        var calcChecksum: UInt32 = 0
        tableLongs.forEach({ calcChecksum &+= $0 })
        //		var calcChecksum : UInt32 = 0
        //		for long in tableLongs {
        //			calcChecksum &+= long
        //		}
        return calcChecksum
    }

    private func calculateSearchParams() {
        numberOfTables = UInt16(entries.count)
        var nextPower: UInt16 = 2
        var log2: UInt16 = 0
        while nextPower <= numberOfTables {
            log2 += 1
            nextPower *= 2
        }
        let powerOf2: UInt16 = nextPower / 2
        searchRange = UInt16(OTFsfntDirectoryEntry.nodeLength) * powerOf2
        entrySelector = log2
        rangeShift = UInt16(OTFsfntDirectoryEntry.nodeLength) * (numberOfTables - powerOf2)
    }

    public override var description: String {
        var description = "OTFsfntDirectory:\n"
        description += "  format: \(format.rawValue.fourCharString)\n"
        description += entries.map(\.description).joined(separator: "\n")
        return description
    }
}

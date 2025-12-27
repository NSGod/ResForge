//
//  KernTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//

import Cocoa
import RFSupport

struct KernTable {
    var numberOfEntries:                Int16              // number of entries - 1
    var entries:                        [KernTableEntry]

    var hasOutOfRangeCharCodes: Bool
    private var fontStylesToEntries:    [MacFontStyle: KernTableEntry]
}

extension KernTable {
    init(_ reader: BinaryDataReader) throws {
        numberOfEntries = try reader.read()
        entries = []
        fontStylesToEntries = [:]
        for _ in 0...numberOfEntries {
            let entry: KernTableEntry = try KernTableEntry(reader)
            entries.append(entry)
            fontStylesToEntries[entry.style] = entry
//            hasOutOfRangeCharCodes |= entry.hasOutOfRangeCharCodes
            hasOutOfRangeCharCodes = hasOutOfRangeCharCodes ? true : entry.hasOutOfRangeCharCodes
        }
    }

    func entry(for fontStyle: MacFontStyle) -> KernTableEntry? {
        return fontStylesToEntries[fontStyle]
    }
}


// MARK: -
struct KernTableEntry {
    var style:      MacFontStyle            /* style the entry applies to */

    /// NOTE: While `numKerns` is defined as a `SInt16`, it makes no sense to have negative kern pairs,
    ///       and I *have* encountered fonts that have more than 32,767 kern pairs, so make it an `UInt16`
    ///
    var numKerns:   UInt16  /// Number of kern entries that follow (and NOT the entryLength/length
                            /// of the data that follows this struct as is documented).

    var kernPairs:  [KernPair]

    var hasOutOfRangeCharCodes: Bool
}

extension KernTableEntry {
    init(_ reader: BinaryDataReader) throws {
        style = try reader.read()
        numKerns = try reader.read()
        kernPairs = []
        for _ in 0..<numKerns {
            let kernPair: KernPair = try KernPair(reader)
            kernPairs.append(kernPair)
            hasOutOfRangeCharCodes = hasOutOfRangeCharCodes ? true : kernPair.hasOutOfRangeCharCodes
        }
    }
}


// MARK: - KernPair
struct KernPair: Equatable {
    var kernFirst:  UInt8           /* 1st character of kerned pair */
    var kernSecond: UInt8           /* 2nd character of kerned pair */
    var kernWidth:  Fixed4Dot12     /* kerning distance, in pixels, for the 2 glyphs at size of 1pt; fixed-point 4.12 format */

    var hasOutOfRangeCharCodes: Bool {
        return kernFirst < 0x20 || kernSecond < 0x20 || kernFirst == 0x7F || kernSecond == 0x7F
    }
}

extension KernPair {
    init(_ reader: BinaryDataReader) throws {
        kernFirst = try reader.read()
        kernSecond = try reader.read()
        kernWidth = try reader.read()
    }
}

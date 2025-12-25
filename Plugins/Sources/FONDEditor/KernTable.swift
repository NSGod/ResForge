//
//  KernTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//

import Cocoa
import RFSupport

struct KernTable {
    var numberOfEntries: Int16              /* number of entries - 1 */
    var entries: [KernTableEntry]
}

struct KernTableEntry {
    var style:      MacFontStyle            /* style the entry applies to */

    /// NOTE: While `numKerns` is defined as a `SInt16`, it makes no sense to have negative kern pairs,
    ///       and I've encountered fonts that have more than 32767 kern pairs, so make it an `UInt16`
    ///
    var numKerns:   UInt16  /// Number of kern entries that follow (and NOT the entryLength/length
                            /// of the data that follows this struct as is documented).

    var kernPairs:  [KernPair]

}

struct KernPair: Equatable {
    var kernFirst: UInt8        /* 1st character of kerned pair */
    var kernSecond: UInt8       /* 2nd character of kerned pair */
    var kernWidth: Fixed4Dot12  /* kerning distance, in pixels, for 2 glyphs at size of 1pth; fixed-point 4.12 format */

    var hasOutOfRangeCharCodes: Bool {
        return kernFirst < 0x20 || kernSecond < 0x20 || kernFirst == 0x7F || kernSecond == 0x7F
    }
}

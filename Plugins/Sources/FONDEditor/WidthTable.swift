//
//  WidthTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//

import Cocoa
import RFSupport

struct WidthTable {
    var numberOfEntries:    Int16               /* number of entries - 1 */
    var entries:            [WidthTableEntry]
}

struct WidthTableEntry {
    var style:      MacFontStyle    // style entry applies to
    var widths:     [Fixed4Dot12]
}

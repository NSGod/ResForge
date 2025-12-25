//
//  OffsetTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//

import Cocoa
import RFSupport

struct OffsetTable {
    var numberOfEntries:    Int16               /* number of entries - 1 */
    var entries:            [OffsetTableEntry]
}

struct OffsetTableEntry {
    var offsetOfTable: Int32    /* number of bytes from START OF THE OFFSET TABLE to the start of the table */
}

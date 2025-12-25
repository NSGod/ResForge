//
//  BoundingBoxTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//

import Cocoa
import RFSupport

struct BoundingBoxTable {
    var numberOfEntries: Int16                      /* number of entries - 1 */
    var entries:         [BoundingBoxTableEntry]
}

struct BoundingBoxTableEntry {
    var fontStyle:  MacFontStyle
    var left:       Fixed4Dot12
    var bottom:     Fixed4Dot12
    var right:      Fixed4Dot12
    var top:        Fixed4Dot12
}

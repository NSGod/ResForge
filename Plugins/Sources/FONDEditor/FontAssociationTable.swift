//
//  FontAssociationTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//

import Cocoa
import RFSupport

struct FontAssociationTable {
    var numberOfEntries:    Int16                       /* number of entries - 1 */
    var entries:            [FontAssociationTableEntry]
}

struct FontAssociationTableEntry: Comparable {
    var fontPointSize:  Int16
    var fontStyle:      MacFontStyle
    var fontID:         ResID

    static func < (lhs: FontAssociationTableEntry, rhs: FontAssociationTableEntry) -> Bool {
        if lhs.fontPointSize != rhs.fontPointSize {
            return lhs.fontPointSize < rhs.fontPointSize
        } else {
            return lhs.fontStyle < rhs.fontStyle
        }
    }

    static func == (lhs: FontAssociationTableEntry, rhs: FontAssociationTableEntry) -> Bool {
        return lhs.fontPointSize == rhs.fontPointSize &&
               lhs.fontStyle == rhs.fontStyle &&
               lhs.fontID == rhs.fontID
    }

}

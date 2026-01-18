//
//  OutlineView.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/17/2026.
//

import Cocoa
import RFSupport

class OutlineView: NSOutlineView {

    // Show the resource menu when right-clicking an item, selecting it if necessary
    override func menu(for event: NSEvent) -> NSMenu? {
        let point = self.convert(event.locationInWindow, from: nil)
        let row = self.row(at: point)
        if row != -1 {
            if !selectedRowIndexes.contains(row) {
                self.selectRowIndexes([row], byExtendingSelection: false)
            }
            return self.menu
        }
        return nil
    }
}

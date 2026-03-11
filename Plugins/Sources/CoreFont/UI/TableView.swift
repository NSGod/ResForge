//
//  TableView.swift
//  CoreFont
//
//  Created by Mark Douma on 3/11/2026.
//

import Cocoa

open class TableView: NSTableView {

    public override func menu(for event: NSEvent) -> NSMenu? {
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

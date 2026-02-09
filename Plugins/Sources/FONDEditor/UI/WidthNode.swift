//
//  WidthNode.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/5/2026.
//

import Foundation
import CoreFont

// for display
final class WidthNode: NSObject {
    @objc let glyphName:    String
    @objc let glyphWidth:   Fixed4Dot12

    init(glyphName: String, glyphWidth: Fixed4Dot12) {
        self.glyphName = glyphName
        self.glyphWidth = glyphWidth
    }

    class func widthNodes(widthTableEntry: WidthTable.Entry) -> [WidthNode] {
        var nodes: [WidthNode] = []
        let fond = widthTableEntry.fond!
        var charCode = fond.firstChar
        for glyphWidth in widthTableEntry.widths {
            if let glyphName = fond.glyphName(for: CharCode(charCode)) {
                let node = WidthNode(glyphName: glyphName, glyphWidth: glyphWidth)
                nodes.append(node)
            }
            if charCode == CharCode.max { break }
            charCode += 1
        }
        return nodes
    }
}

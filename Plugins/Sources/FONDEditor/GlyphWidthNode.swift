//
//  GlyphWidthNode.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/5/2026.
//

import Cocoa

// for display
final class GlyphWidthNode: NSObject {
    let glyphName:  String
    let glyphWidth: Fixed4Dot12

    init(glyphName: String, glyphWidth: Fixed4Dot12) {
        self.glyphName = glyphName
        self.glyphWidth = glyphWidth
    }

    class func glyphWidthNodes(widthTableEntry: WidthTableEntry) -> [GlyphWidthNode] {
        var nodes: [GlyphWidthNode] = []
        let fond = widthTableEntry.fond
        var charCode = fond.firstChar
        for glyphWidth in widthTableEntry.widths {
            if let glyphName = fond.glyphName(for: CharCode(charCode)) {
                let node = GlyphWidthNode(glyphName: glyphName, glyphWidth: glyphWidth)
                nodes.append(node)
            }
            charCode += 1
        }
        return nodes
    }
}

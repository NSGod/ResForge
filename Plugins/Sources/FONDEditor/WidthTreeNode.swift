//
//  WidthTreeNode.swift
//  Plugins
//
//  Created by Mark Douma on 1/5/2026.
//

import Cocoa

class WidthTreeNode: NSTreeNode {

    override init(representedObject: Any?) {
        super.init(representedObject: representedObject)
    }

    init(with widthTableEntry: WidthTableEntry) {
        var mTreeNodes: [WidthTreeNode] = []
        let glyphWidthNodes = GlyphWidthNode.glyphWidthNodes(widthTableEntry: widthTableEntry)
        for node in glyphWidthNodes {
            let treeNode = WidthTreeNode(representedObject:node)
            mTreeNodes.append(treeNode)
        }
        super.init(representedObject: widthTableEntry)
        self.mutableChildren.addObjects(from: mTreeNodes)
    }

    var countOfChildNodes: Int {
        return self.children?.count ?? 0
    }
}

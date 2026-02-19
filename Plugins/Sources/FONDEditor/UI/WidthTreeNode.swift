//
//  WidthTreeNode.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/5/2026.
//

import Cocoa
import CoreFont

final class WidthTreeNode: NSTreeNode, Comparable {

    override init(representedObject modelObject: Any?) {
        if let entry = modelObject as? FOND.WidthTable.Entry {
            var mTreeNodes: [WidthTreeNode] = []
            let widthNodes: [WidthNode] = WidthNode.widthNodes(widthTableEntry: entry)
            for node in widthNodes {
                let treeNode = WidthTreeNode(representedObject: node)
                mTreeNodes.append(treeNode)
            }
            let treeNodes = mTreeNodes.sorted(by: <)
            super.init(representedObject: entry)
            mutableChildren.addObjects(from: treeNodes)
        } else {
            super.init(representedObject: modelObject)
        }
    }

    @objc var countOfChildNodes: Int {
        return self.children?.count ?? 0
    }

    static func < (lhs: WidthTreeNode, rhs: WidthTreeNode) -> Bool {
        /// `representedObject` can be either `WidthNode` or `WidthTable.Entry`
        if let lhs = lhs.representedObject as? FOND.WidthTable.Entry, let rhs = rhs.representedObject as? FOND.WidthTable.Entry {
            return lhs.style < rhs.style
        }
        return false
    }
}

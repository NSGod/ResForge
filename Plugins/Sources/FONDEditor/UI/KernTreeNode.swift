//
//  KernTreeNode.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/5/2026.
//

import Cocoa

final class KernTreeNode: NSTreeNode, Comparable {

    override init(representedObject modelObject: Any?) {
        if let entry = modelObject as? KernTable.Entry {
            var mKernTreeNodes: [KernTreeNode] = []
            entry.fond.encoding.logsInvalidCharCodes = true
            for kernPair in entry.kernPairs {
                /// don't create a kern pair if value is 0
                if kernPair.kernWidth == 0 { continue }
                let pairNode = KernPairNode(with: kernPair, fond: entry.fond)
                let treeNode = KernTreeNode(representedObject: pairNode)
                mKernTreeNodes.append(treeNode)
            }
            let kernTreeNodes = mKernTreeNodes.sorted(by: <)
            super.init(representedObject: entry)
            mutableChildren.addObjects(from: kernTreeNodes)
            entry.fond.encoding.logsInvalidCharCodes = false
        } else {
            super.init(representedObject: modelObject)
        }
    }

    @objc var countOfChildNodes: Int {
        return self.children?.count ?? 0
    }

    static func < (lhs: KernTreeNode, rhs: KernTreeNode) -> Bool {
        /// `representedObject` can be either a `KernTable.Entry` or a `KernPairNode`
        if let lhs = lhs.representedObject as? KernTable.Entry, let rhs = rhs.representedObject as? KernTable.Entry {
            return lhs.style < rhs.style
        }
        return false
    }
}

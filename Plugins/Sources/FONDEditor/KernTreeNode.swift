//
//  KernTreeNode.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/5/2026.
//

import Cocoa

final class KernTreeNode: NSTreeNode, Comparable {

    override init(representedObject modelObject: Any?) {
        super.init(representedObject: modelObject)
    }

    init(_ entry: KernTableEntry) {
        var mKernPairNodes: [KernTreeNode] = []
        entry.fond.encoding.logsInvalidCharCodes = true
        for kernPair in entry.kernPairs {
            // don't create a kern pair if value is 0
            if kernPair.kernWidth == 0 { continue }
            let pairNode = KernPairNode(with: kernPair, fond: entry.fond)
            let node = KernTreeNode(representedObject: pairNode)
            mKernPairNodes.append(node)
        }
        let kernPairNodes = mKernPairNodes.sorted(by: <)
        super.init(representedObject: entry)
        self.mutableChildren.add(kernPairNodes)
    }

    var countOfChildNodes: Int {
        return self.children?.count ?? 0
    }

    func localizedStandardCompare(_ otherNode: KernTreeNode) -> ComparisonResult {
        // represented object can be either KernPairNode or KernTableEntry
        if let lhs = self.representedObject as? KernPairNode, let rhs = otherNode.representedObject as? KernPairNode {
            return lhs.localizedStandardCompare(rhs)
        }
        return .orderedSame
    }

    static func <(lhs: KernTreeNode, rhs: KernTreeNode) -> Bool {
        return lhs.localizedStandardCompare(rhs) == .orderedAscending
    }
}

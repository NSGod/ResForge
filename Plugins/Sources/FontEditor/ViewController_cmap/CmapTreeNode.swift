//
//  CmapTreeNode.swift
//  FontEditor
//
//  Created by Mark Douma on 2/25/2026.
//

import Cocoa
import CoreFont

final class CmapTreeNode: NSTreeNode {

    override init(representedObject: Any?) {
        super.init(representedObject: representedObject)
    }

    init(with encoding: FontTable_cmap.Encoding) {
        super.init(representedObject: encoding)
        let mappingNodes: [CmapTreeNode] = encoding.subtable.glyphMappings.map { CmapTreeNode(representedObject: $0) }
        mutableChildren.addObjects(from: mappingNodes)
    }

    @objc var countOfChildNodes: Int {
        return self.children?.count ?? 0
    }
}

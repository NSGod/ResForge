//
//  FeatTreeNode.swift
//  FontEditor
//
//  Created by Mark Douma on 2/27/2026.
//

import Cocoa
import CoreFont

final class FeatTreeNode: NSTreeNode {
    override init(representedObject: Any?) {
        super.init(representedObject: representedObject)
    }

    init(with featureName: FontTable_feat.FeatureName) {
        super.init(representedObject: featureName)
		let mChildNodes: [FeatTreeNode] = featureName.settings.map { FeatTreeNode(representedObject: $0) }
        mutableChildren.addObjects(from: mChildNodes)
    }

    @objc var countOfChildNodes: Int {
        return self.children?.count ?? 0
    }
}

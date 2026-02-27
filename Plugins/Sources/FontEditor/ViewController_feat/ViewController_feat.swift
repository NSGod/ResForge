//
//  ViewController_feat.swift
//  FontEditor
//
//  Created by Mark Douma on 2/27/2026.
//

import Cocoa
import CoreFont

final class ViewController_feat: FontTableViewController {
    var table:                      FontTable_feat
    @objc dynamic var featureNames: [FeatTreeNode] = []

    required init?(with fontTable: FontTable) {
        table = fontTable as! FontTable_feat
        super.init(with: fontTable)
        for featureName in table.featureNames {
            featureNames.append(.init(with: featureName))
        }
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

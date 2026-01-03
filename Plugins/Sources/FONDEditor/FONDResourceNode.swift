//
//  FONDResourceNode.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/1/2026.
//

import Foundation

class FONDResourceNode: ResourceNode {
    unowned var fond:   FOND    // weak

    init(fond: FOND) {
        self.fond = fond
        super.init()
    }
}

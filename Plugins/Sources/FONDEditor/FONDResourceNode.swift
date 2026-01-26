//
//  FONDResourceNode.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/1/2026.
//

import Foundation

public class FONDResourceNode: ResourceNode {
    public unowned var fond:   FOND    // weak

    public init(fond: FOND) {
        self.fond = fond
        super.init()
    }
}

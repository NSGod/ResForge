//
//  NFNTTextContainer.swift
//  CoreFont
//
//  Created by Mark Douma on 1/14/2026.
//

import Foundation

public final class NFNTTextContainer {
    public var size:                   NSSize {
        didSet {
            guard let layoutManager else { return }
            layoutManager.textContainerChangedGeometry(self)
        }
    }

    public weak var layoutManager:  NFNTLayoutManager!

    public init(size: NSSize) {
        self.size = size
    }
}

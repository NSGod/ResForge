//
//  NFNTTextContainer.swift
//  BitmapFontEditor
//
//  Created by Mark Douma on 1/14/2026.
//

import Foundation
import RFSupport

class NFNTTextContainer {
    var size:                   NSSize {
        didSet {
            guard let layoutManager else { return }
            layoutManager.textContainerChangedGeometry(self)
        }
    }

    weak var layoutManager:  NFNTLayoutManager!

    init(size: NSSize) {
        self.size = size
    }
}

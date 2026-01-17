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
//            NSLog("\(type(of: self)).\(#function) size did change: \(size)")
            guard let layoutManager else { return }
            layoutManager.textContainerChangedGeometry(self)
        }
    }

    weak var layoutManager:  NFNTLayoutManager!

    init(size: NSSize) {
        self.size = size
    }
}

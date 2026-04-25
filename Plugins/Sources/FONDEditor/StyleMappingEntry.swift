//
//  StyleMappingEntry.swift
//  FONDEditor
//
//  Created by Mark Douma on 4/25/2026.
//

import Cocoa
import CoreFont
import RFSupport

public final class StyleMappingEntry: NSObject {
    public var style:                       MacFontStyle = .regular
    @objc dynamic public var stringIndex:   Int = 0

    public init(compressedStyle: MacFontStyle, stringIndex: Int) {
        self.style = compressedStyle.uncompressed()
        self.stringIndex = stringIndex
    }
}

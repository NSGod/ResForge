//
//  FEGlyph.swift
//  FontEditor
//
//  Created by Mark Douma on 4/12/2026.
//

import Cocoa
import CoreFont

// UI/objc-wrapper around UIGlyph
public class FEGlyph: NSObject {
    @objc dynamic public var glyphName:    String
    @objc dynamic public var glyphID:      GlyphID
    public var glyph:                      UIGlyph

    public init(with glyph: UIGlyph) {
        self.glyph = glyph
        glyphName = glyph.glyphName
        glyphID = glyph.glyphID
        super.init()
    }
}

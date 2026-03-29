//
//  UIBitmapGlyph.swift
//  FontEditor
//
//  Created by Mark Douma on 3/28/2026.
//

import Cocoa
import CoreFont

public final class UIBitmapGlyph: NSObject, Comparable {

    var glyph:                  Sbit.BitmapGlyph
    @objc let glyphID:          GlyphID
    @objc lazy var glyphName:   String = {
        return glyph.strike.fontFile.glyphName(for: glyphID)
    }()

    public init(with bitmapGlyph: Sbit.BitmapGlyph) {
        glyph = bitmapGlyph
        glyphID = bitmapGlyph.glyphID
        super.init()
    }

    public static func bitmapGlyphs(with strike: UIBitmapStrike) -> [UIBitmapGlyph] {
        return strike.strike.glyphs.map { UIBitmapGlyph(with: $0) }
    }

    public static func < (lhs: UIBitmapGlyph, rhs: UIBitmapGlyph) -> Bool {
        return lhs.glyph < rhs.glyph
    }

    public static func == (lhs: UIBitmapGlyph, rhs: UIBitmapGlyph) -> Bool {
        return lhs.glyph == rhs.glyph
    }
}

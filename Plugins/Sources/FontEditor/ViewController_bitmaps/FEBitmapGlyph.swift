//
//  FEBitmapGlyph.swift
//  FontEditor
//
//  Created by Mark Douma on 3/28/2026.
//

import Cocoa
import CoreFont

/// UI/objc-wrapper around `Sbit.BitmapGlyph`
public final class FEBitmapGlyph: NSObject, Comparable {
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

    public static func bitmapGlyphs(with strike: FEBitmapStrike) -> [FEBitmapGlyph] {
        return strike.strike.glyphs.map { FEBitmapGlyph(with: $0) }
    }

    public static func < (lhs: FEBitmapGlyph, rhs: FEBitmapGlyph) -> Bool {
        return lhs.glyph < rhs.glyph
    }

    public static func == (lhs: FEBitmapGlyph, rhs: FEBitmapGlyph) -> Bool {
        return lhs.glyph == rhs.glyph
    }
}

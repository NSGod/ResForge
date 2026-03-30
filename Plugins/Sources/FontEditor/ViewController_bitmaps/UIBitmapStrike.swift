//
//  UIBitmapStrike.swift
//  FontEditor
//
//  Created by Mark Douma on 3/28/2026.
//

import Cocoa
import CoreFont

public final class UIBitmapStrike: NSObject {
    @objc dynamic public let pointSize:     CGFloat
    @objc dynamic public var glyphs:        [UIBitmapGlyph] = []
    public var strike:                      Sbit.BitmapStrike

    public init(with bitmapStrike: Sbit.BitmapStrike) {
        pointSize = CGFloat(bitmapStrike.sizeTable.ppemX)
        strike = bitmapStrike
        super.init()
        glyphs = UIBitmapGlyph.bitmapGlyphs(with: self)
    }

    public static func bitmapStrikes(with strikes: [Sbit.BitmapStrike]) -> [UIBitmapStrike] {
        return strikes.map { UIBitmapStrike(with: $0) }
    }
}

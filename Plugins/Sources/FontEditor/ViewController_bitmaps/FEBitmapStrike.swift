//
//  FEBitmapStrike.swift
//  FontEditor
//
//  Created by Mark Douma on 3/28/2026.
//

import Cocoa
import CoreFont

/// UI/objc-wrapper around `Sbit.BitmapStrike`
public final class FEBitmapStrike: NSObject {
    @objc dynamic public let pointSize:     CGFloat
    @objc dynamic public var glyphs:        [FEBitmapGlyph] = []
    public var strike:                      Sbit.BitmapStrike

    public init(with bitmapStrike: Sbit.BitmapStrike) {
        pointSize = CGFloat(bitmapStrike.sizeTable.ppemX)
        strike = bitmapStrike
        super.init()
        glyphs = FEBitmapGlyph.bitmapGlyphs(with: self)
    }

    public static func bitmapStrikes(with strikes: [Sbit.BitmapStrike]) -> [FEBitmapStrike] {
        return strikes.map { FEBitmapStrike(with: $0) }
    }
}

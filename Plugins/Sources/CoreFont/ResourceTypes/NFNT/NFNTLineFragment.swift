//
//  NFNTLineFragment.swift
//  CoreFont
//
//  Created by Mark Douma on 1/14/2026.
//

import Cocoa

public final class NFNTLineFragment {
    public var frame:              NSRect

    public var alignedFrame:       NSRect {
        var _alignedFrame = frame
        if alignment == .center {
            _alignedFrame.origin.x = floor((NSWidth(frame) - widthOfGlyphs) / 2)
        } else if alignment == .right {
            _alignedFrame.origin.x = floor(NSWidth(frame) - widthOfGlyphs)
        }
        return _alignedFrame
    }

    public var generatedGlyphs:    [NFNT.Glyph] = []
    public var alignment:          NSTextAlignment

    private var widthOfGlyphs: CGFloat = 0

    public init(frame: NSRect, alignment: NSTextAlignment) {
        self.frame = frame
        self.alignment = alignment
    }

    public func add(_ glyph: NFNT.Glyph) {
        generatedGlyphs.append(glyph)
        widthOfGlyphs += CGFloat((glyph.nfnt?.kernMax ?? 0) + Int16(glyph.offset) + Int16(glyph.width))
    }
}

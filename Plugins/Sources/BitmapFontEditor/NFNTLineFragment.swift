//
//  NFNTLineFragment.swift
//  BitmapFontEditor
//
//  Created by Mark Douma on 1/14/2026.
//

import Cocoa
import RFSupport

class NFNTLineFragment {
    var frame:              NSRect

    var alignedFrame:       NSRect {
        var _alignedFrame = frame
        if alignment == .center {
            _alignedFrame.origin.x = floor((NSWidth(frame) - generatedGlyphWidths) / 2)
        } else if alignment == .right {
            _alignedFrame.origin.x = floor(NSWidth(frame) - generatedGlyphWidths)
        }
        return _alignedFrame
    }

    var generatedGlyphs:    [NFNT.Glyph] = []
    var alignment:          NSTextAlignment

    private var generatedGlyphWidths: CGFloat = 0

    init(with frame: NSRect, alignment: NSTextAlignment) {
        self.frame = frame
        self.alignment = alignment
    }

    func add(_ glyph: NFNT.Glyph) {
        generatedGlyphs.append(glyph)
        generatedGlyphWidths += CGFloat(((glyph.nfnt.kernMax + Int16(glyph.offset)) + Int16(glyph.width)))
    }
}

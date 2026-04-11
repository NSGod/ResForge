//
//  UIGlyphView.swift
//  FontEditor
//
//  Created by Mark Douma on 4/9/2026.
//

import Cocoa
import CoreFont

public final class UIGlyphView: NSView {

    public enum Fit {
        case all
        case glyph
    }

    public var glyph:               UIGlyph?
    public var glyphFit:            Fit = .all
    public var transform:           AffineTransform = .identity
    public var shouldDrawMetrics:   Bool {
        return NSHeight(bounds) >= 128.0
    }

    private var metrics:            NSBezierPath?

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    public required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    public override func draw(_ dirtyRect: NSRect) {
        let bounds = bounds
        glyphFit == .all ? NSColor.white.setFill() : NSColor.clear.setFill()
        NSBezierPath.fill(bounds)
        NSBezierPath.defaultLineWidth = 1.0
        glyphFit == .glyph ? NSColor.black.setStroke() : NSColor.red.setStroke()
        NSBezierPath.stroke(bounds.insetBy(dx: -0.5, dy: -0.5))
        guard let glyph else { return }


    }
    

}

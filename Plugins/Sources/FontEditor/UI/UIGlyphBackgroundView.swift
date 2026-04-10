//
//  UIGlyphBackgroundView.swift
//  FontEditor
//
//  Created by Mark Douma on 4/10/2026.
//

import Cocoa

public final class UIGlyphBackgroundView: NSView {

    @IBInspectable var selectionColor: NSColor? = .controlAccentColor

    @IBInspectable var backgroundColor: NSColor? = .white

    public var isSelected: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    public var bezierPath: NSBezierPath?

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func resizeSubviews(withOldSize oldSize: NSSize) {
        bezierPath = nil
        super.resizeSubviews(withOldSize: oldSize)
    }

    public override func resize(withOldSuperviewSize oldSize: NSSize) {
        bezierPath = nil
        super.resize(withOldSuperviewSize: oldSize)
    }

    public override func draw(_ dirtyRect: NSRect) {
        let bounds = self.bounds
        if bezierPath == nil {
            bezierPath = NSBezierPath(roundedRect: bounds, xRadius: 5.0, yRadius: 5.0)
        }
        if isSelected {
            selectionColor?.setFill()
            bezierPath?.fill()
        } else {
            backgroundColor?.setFill()
            NSBezierPath.fill(bounds)
        }
    }
}

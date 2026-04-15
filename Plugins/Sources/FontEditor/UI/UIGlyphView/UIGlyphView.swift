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

    public var glyph: UIGlyph? {
        didSet {
            transform = .identity
            needsDisplay = true
        }
    }

    public var glyphFit:            Fit = .glyph
    public var transform:           AffineTransform = .identity
    public var shouldDrawMetrics:   Bool {
        return NSHeight(bounds) >= 128.0
    }

    private var metrics:            NSBezierPath!

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func draw(_ dirtyRect: NSRect) {
        let bounds = bounds
        glyphFit == .all ? NSColor.white.setFill() : NSColor.clear.setFill()
        NSBezierPath.fill(bounds)
        NSBezierPath.defaultLineWidth = 1.0
        glyphFit == .all ? NSColor.red.setStroke() : NSColor.black.setStroke()
        NSBezierPath.stroke(bounds.insetBy(dx: -0.5, dy: -0.5))
        guard let glyph else { return }
        let yMax = glyph.metricsProvider.metrics.boundingRectForFont.maxY
        let ascender = glyph.metricsProvider.metrics.ascender
        // FIXME: !! or should this be glyph.metricsProvider.metrics.boundingRectForFont.minY?
        // FIXME: I think so
        // let yMin = glyph.metricsProvider.metrics.descender
        let yMin = glyph.metricsProvider.metrics.boundingRectForFont.minY
        let capHeight = glyph.metricsProvider.metrics.capHeight
        let xHeight = glyph.metricsProvider.metrics.xHeight
        let italicAngle = glyph.metricsProvider.metrics.italicAngle
        let totalHeight = yMax + abs(yMin)
        var scaleFactor = 1.0
        if glyphFit == .all {
            scaleFactor = (bounds.height - 20.0)/totalHeight
        } else {
            scaleFactor = bounds.height/totalHeight
        }
        let drawRect = (glyphFit == .all ? NSInsetRect(bounds, 10.0, 10.0) : bounds)
        if shouldDrawMetrics {
            // FIXME: !! set line width to 1.0 and draw on the 0.5 half pixel/point line to create clean 1 px wide lines
            metrics = NSBezierPath()
            metrics.lineWidth = 1.0
            metrics.move(to: drawRect.origin)
            // descender:
            metrics.line(to: NSPoint(x: drawRect.maxX, y: drawRect.origin.y))
            // ascender:
            metrics.move(to: NSPoint(x: drawRect.origin.x, y: drawRect.origin.y + (abs(yMin) + ascender) * scaleFactor))
            metrics.line(to: NSPoint(x: drawRect.maxX, y: metrics.currentPoint.y))
        }
        var baselineStart = drawRect.origin
        baselineStart.y += abs(yMin) * scaleFactor
        var baselineStop = baselineStart
        baselineStop.x += drawRect.width
        if shouldDrawMetrics {
            metrics.move(to: baselineStart)
            metrics.line(to: baselineStop)
            if xHeight > 0 && capHeight > 0 {
                var startPoint = drawRect.origin
                startPoint.y += (abs(yMin) + xHeight) * scaleFactor
                var stopPoint = NSPoint(x: drawRect.maxX, y: startPoint.y)
                /// xHeight
                metrics.move(to: startPoint)
                metrics.line(to: stopPoint)
                startPoint = NSPoint(x: drawRect.minX, y: drawRect.origin.y + (abs(yMin) + capHeight) * scaleFactor)
                stopPoint = NSPoint(x: drawRect.maxX, y: startPoint.y)
                /// capHeight
                metrics.move(to: startPoint)
                metrics.line(to: stopPoint)
            }
        }
        let origin = NSPoint(x: floor(drawRect.midX - floor(glyph.advanceWidth * scaleFactor) / 2.0), y: baselineStart.y)
        if shouldDrawMetrics {
            /// left sidebearing
            var sideBearingStart = NSPoint(x: origin.x, y: drawRect.minY)
            var sideBearingStop = NSPoint(x: origin.x, y: drawRect.maxY)
            var italicTopShift = 0.0
            var italicBottomShift = 0.0
            if italicAngle != 0 {
                italicTopShift = tan(abs(italicAngle).degreesToRadians) * (sideBearingStop.y - baselineStart.y)
                italicBottomShift = tan(abs(italicAngle).degreesToRadians) * (baselineStart.y - sideBearingStart.y)
            }
            sideBearingStop.x += italicTopShift
            sideBearingStart.x -= italicBottomShift
            metrics.move(to: sideBearingStart)
            metrics.line(to: sideBearingStop)
            /// right sidebearing
            let rightSidebearing = floor(drawRect.midX + floor(glyph.advanceWidth * scaleFactor) / 2.0)
            sideBearingStart = NSPoint(x: rightSidebearing - italicBottomShift, y: drawRect.minY)
            sideBearingStop = NSPoint(x: rightSidebearing + italicTopShift, y: drawRect.maxY)
            metrics.move(to: sideBearingStart)
            metrics.line(to: sideBearingStop)
            NSColor.tertiaryLabelColor.setStroke()
            /// use a (+0.5 px, +0.5 px) transform to align 1pt thick lines to integral dimensions
            let transform = AffineTransform(translationByX: 0.5, byY: 0.5)
            metrics.transform(using: transform)
            metrics.stroke()
        }
        if transform == .identity {
            transform.translate(x: origin.x, y: origin.y)
            transform.scale(scaleFactor)
        }
        NSGraphicsContext.saveGraphicsState()
        (transform as NSAffineTransform).concat()
        NSColor.black.set()
        glyph.bezierPath?.fill()
        NSGraphicsContext.restoreGraphicsState()
    }
}

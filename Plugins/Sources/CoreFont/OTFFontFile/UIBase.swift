//
//  UIBase.swift
//  CoreFont
//
//  Created by Mark Douma on 4/9/2026.
//

import Cocoa

public protocol UIGlyph {
    var glyphID:            GlyphID             { get }
    var glyphName:          String              { get }

    var bezierPath:         NSBezierPath?       { get }

    var glyphsProvider:     UIGlyphsProvider?   { get } /// weak
    var metricsProvider:    UIMetricsProvider?  { get } /// weak
}

public protocol UIGlyphsProvider {
    var glyphs:          [UIGlyph] { get }

    func glyph<T: FixedWidthInteger>(for glyphID: T) -> UIGlyph?
    func glyph(for uv: UVBMP) -> UIGlyph?

    /// optional
    func glyphName<T: FixedWidthInteger>(for glyphID: T) -> String?
}

extension UIGlyphsProvider {
    /// optional
    public func glyphName<T: FixedWidthInteger>(for glyphID: T) -> String? {
        return nil
    }
}

public protocol UIMetricsProvider {
    var metrics:          UIFontMetrics { get }
}

public protocol UIFontMetrics {
    var unitsPerEm:             UnitsPerEm  { get }
    /// the following are all intended to be expressed in units per em,
    /// not scaled to a particular font point size:
    var boundingRectForFont:    NSRect      { get }

    var ascender:               CGFloat     { get }
    var descender:              CGFloat     { get }
    var capHeight:              CGFloat     { get }
    var xHeight:                CGFloat     { get }
    var leading:                CGFloat     { get } /// may be calculated
                                                    ///
    var lineHeight:             CGFloat     { get }

    var italicAngle:            CGFloat     { get }
}

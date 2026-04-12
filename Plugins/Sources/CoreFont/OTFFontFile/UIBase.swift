//
//  UIBase.swift
//  CoreFont
//
//  Created by Mark Douma on 4/9/2026.
//

import Cocoa

public protocol UIGlyph: FontAwaking {
    var glyphID:            GlyphID             { get }
    var glyphName:          String              { get set }

    var uv:                 UV                  { get set } // primary UV
    var additionalUVs:      IndexSet?           { get set } // UVs; nil if none or CID-based
    var allUVs:             IndexSet?           { get set } // UVs; nil if CID-based

    var bezierPath:         NSBezierPath?       { get }

    var xMin:               CGFloat             { get }
    var yMin:               CGFloat             { get }
    var xMax:               CGFloat             { get }
    var yMax:               CGFloat             { get }

    var advanceWidth:       CGFloat             { get }

    var glyphsProvider:     UIGlyphsProvider!   { get } /// weak
    var metricsProvider:    UIMetricsProvider!  { get } /// weak
}


public protocol UIGlyphsProvider: AnyObject {
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


public protocol UIMetricsProvider: AnyObject {
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

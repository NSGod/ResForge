//
//  Styl.Style.swift
//  CoreFont
//
//  Created by Mark Douma on 7/8/2026.
//

import Cocoa

extension NSAttributedString.Key {
    public static let stylStyle     = NSAttributedString.Key("Styl.Style")
}

extension Styl {
    // MARK: -
    /// working model class that's stored as a `.stylStyle` attribute in the attributed string
    public final class Style: CustomStringConvertible, Equatable {
        public var fontFamilyID:    ResID = .systemFont
        public var fontStyle:       MacFontStyle = .regular
        public var fontPointSize:   Int = 12
        public var color:           NSColor = .black

        public var attrs:           [NSAttributedString.Key: Any] = [:]

        private static var fontsAreSetup: Bool = false

        public static let `default`: Style = .init(fontFamilyID: .systemFont, fontStyle: .regular, fontPointSize: 12, color: .black)

        public init(fontFamilyID: ResID, fontStyle: MacFontStyle, fontPointSize: Int, color: NSColor) {
            self.fontFamilyID = fontFamilyID
            self.fontStyle = fontStyle
            self.fontPointSize = fontPointSize
            self.color = color
            self.attrs = Self.attributes(for: self)
        }

        public static func == (lhs: Styl.Style, rhs: Styl.Style) -> Bool {
            return lhs.fontFamilyID == rhs.fontFamilyID &&
            lhs.fontStyle == rhs.fontStyle &&
            lhs.fontPointSize == rhs.fontPointSize &&
            lhs.color == rhs.color
        }

        public var description: String {
            if self == .default { return "default" }
            return "(\(fontFamilyID)) \(FOND.fontFamilyName(for: fontFamilyID)), \(fontStyle) \(fontPointSize) \(color)"
        }

        public static func attributes(for style: Style) -> [NSAttributedString.Key: Any] {
            var attrs: [NSAttributedString.Key: Any] = [:]
            if Self.fontsAreSetup == false {
                do {
                    try FontActivationManager.default.activateFontFile(forResource: "Briquette", withExtension: "otf")
                    try FontActivationManager.default.activateFontFile(forResource: "Evanston", withExtension: "otf")
                    try FontActivationManager.default.activateFontFile(forResource: "Uppercase", withExtension: "otf")
                } catch {
                    NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
                }
                Self.fontsAreSetup = true
            }
            let fontName = FOND.fontFamilyName(for: style.fontFamilyID)
            attrs[.foregroundColor] = style.color
            var font = NSFont(name: fontName, size: CGFloat(style.fontPointSize)) ?? NSFont.monospacedSystemFont(ofSize: CGFloat(style.fontPointSize), weight: .regular)
            if style.fontStyle.contains(.bold) {
                font = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
                if !NSFontManager.shared.traits(of: font).contains(.boldFontMask) {
                    /// If we don't have intrinsic bold, synthesize bold using a slight stroke width.
                    /// Using a negative stroke width allows for both stroke and fill.
                    /// See: Technical Q&A QA1531: Drawing attributed strings that are both filled and stroked
                    /// https://developer.apple.com/library/archive/qa/qa1531/_index.html#//apple_ref/doc/uid/DTS40007490
                    attrs[.strokeWidth] = -font.pointSize * 0.2
                }
            }
            if style.fontStyle.contains(.italic) {
                let newFont = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)
                if NSFontManager.shared.traits(of: newFont).contains(.italicFontMask) {
                    font = newFont
                } else {
                    let obliqueTransform = AffineTransform(m11: newFont.pointSize,
                                                           m12: tan(0.degreesToRadians),
                                                           m21: tan(20.0.degreesToRadians) * newFont.pointSize,
                                                           m22: newFont.pointSize, tX: 0, tY: 0)
                    font = NSFont(descriptor: font.fontDescriptor, textTransform: obliqueTransform) ?? font
                }
            }
            if style.fontStyle.contains(.shadow) {
                /// `NSColor.clear` doesn't work; perhaps it's not opaque, so can't cast shadow?
                attrs[.foregroundColor] = NSColor.white
                let shadow = NSShadow()
                shadow.shadowColor = style.color
                shadow.shadowOffset = NSSize(width: 2.0, height: -2.0)
                attrs[.shadow] = shadow
                // attrs[.strokeColor] = color
                // attrs[.strokeWidth] = -1
            }
            if style.fontStyle.contains(.outline) {
                attrs[.strokeWidth] = 2.0
                attrs[.strokeColor] = style.color
                if style.fontStyle.contains(.underline) {
                    attrs[.underlineStyle] = NSUnderlineStyle.double.rawValue
                }
            }
            if style.fontStyle.contains(.underline) && !style.fontStyle.contains(.outline) {
                attrs[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
            if style.fontStyle.contains(.condensed) {
                /// Note that some fonts like `Impact` are already considered Condensed (via `OS/2.usWidthClass`)
                /// so we won't apply a synthetic transform to it.
                let newFont = NSFontManager.shared.convert(font, toHaveTrait: .condensedFontMask)
                if NSFontManager.shared.traits(of: newFont).contains(.condensedFontMask) {
                    font = newFont
                } else {
                    /// be sure to apply to any existing text transform we already have from synth styles added above
                    var finalTform = font.textTransform
                    if finalTform == .identity {
                        finalTform = AffineTransform(scaleByX: newFont.pointSize * 0.82, byY: newFont.pointSize * 1.0)
                    } else {
                        finalTform.append(AffineTransform(scaleByX: 0.82, byY: 1.0))
                    }
                    font = NSFont(descriptor: font.fontDescriptor, textTransform: finalTform) ?? font
                }
            } else if style.fontStyle.contains(.extended) {
                let newFont = NSFontManager.shared.convert(font, toHaveTrait: .expandedFontMask)
                if NSFontManager.shared.traits(of: newFont).contains(.expandedFontMask) {
                    font = newFont
                } else {
                    /// be sure to apply to any existing text transform we already have from synth styles added above
                    var finalTform = font.textTransform
                    if finalTform == .identity {
                        finalTform = AffineTransform(scaleByX: newFont.pointSize * 1.17, byY: newFont.pointSize * 1.0)
                    } else {
                        finalTform.append(AffineTransform(scaleByX: 1.17, byY: 1.0))
                    }
                    font = NSFont(descriptor: font.fontDescriptor, textTransform: finalTform) ?? font
                }
            }
            attrs[.font] = font
            attrs[.stylStyle] = style
            return attrs
        }
    }
}

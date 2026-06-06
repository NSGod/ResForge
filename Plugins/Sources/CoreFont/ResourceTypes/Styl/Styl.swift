//
//  Styl.swift
//  CoreFont
//
//  Created by Mark Douma on 5/26/2026.
//

import Cocoa
import RFSupport

/// represents a `styl` resource

public final class Styl: CFResource {
    public var numRuns:     Int = 0
    public var runs:        [Run] = []

    public var resource:    Resource
    private var reader:     BinaryDataReader

    public init(with resource: Resource, count textCount: Int) throws {
        self.resource = resource
        reader = BinaryDataReader(resource.data)
        numRuns = Int(try reader.read() as Int16)
        runs = try (0..<numRuns).map { _ in try Run(reader, count: textCount) }
    }

    public func data() throws -> Data {
        let handle = DataHandle()
        numRuns = runs.count
        handle.write(Int16(numRuns))
        try runs.forEach { try $0.write(to: handle) }
        return handle.data
    }

    public func runs(in range: NSRange) -> [Run] {
        var mRuns: [Run] = []
        for run in runs {
            if run.range.intersection(range) != nil {
                mRuns.append(run)
            }
        }
        return mRuns
    }
}

extension NSAttributedString.Key {
    public static let stylStyle     = NSAttributedString.Key("Styl.Style")
}

extension Styl {

    public final class Style: CustomStringConvertible {
        public var fontFamilyID:    ResID = 0
        public var fontStyle:       MacFontStyle = .regular
        public var fontPointSize:   Int = 0
        public var color:           NSColor = .black

        public var attrs:           [NSAttributedString.Key: Any] = [:]

        private static var briquetteIsSetup: Bool = false

        public init(fontFamilyID: ResID, fontStyle: MacFontStyle, fontPointSize: Int, color: NSColor) {
            self.fontFamilyID = fontFamilyID
            self.fontStyle = fontStyle
            self.fontPointSize = fontPointSize
            self.color = color
            self.attrs = Self.attributes(for: self)
        }

        public var description: String {
            "\(fontFamilyID) \(fontStyle) \(fontPointSize) \(color)"
        }

        public static func attributes(for style: Style) -> [NSAttributedString.Key: Any] {
            var attrs: [NSAttributedString.Key: Any] = [:]
            if Self.briquetteIsSetup == false {
                do {
                    try FontActivationManager.default.activateFontFile(forResource: "Briquette", withExtension: "otf")
                } catch {
                    NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
                }
                Self.briquetteIsSetup = true
            }
            let fontName = FOND.fontFamilyName(for: style.fontFamilyID)
            attrs[.foregroundColor] = style.color
            var font = NSFont(name: fontName, size: CGFloat(style.fontPointSize)) ?? NSFont.monospacedSystemFont(ofSize: CGFloat(style.fontPointSize), weight: .regular)
            if style.fontStyle.contains(.bold) {
                font = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
                if !NSFontManager.shared.traits(of: font).contains(.boldFontMask) {
                    /// using negative stroke width allows for both stroke and fill
                    /// Technical Q&A QA1531
                    /// Drawing attributed strings that are both filled and stroked
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
                /// `NSColor.clear` doesn't work; not opaque, so can't cast shadow?
                attrs[.foregroundColor] = NSColor.white
                let shadow = NSShadow()
                shadow.shadowColor = style.color
                shadow.shadowOffset = NSSize(width: 2.0, height: -2.0)
                attrs[.shadow] = shadow
                // attrs[.strokeColor] = color
                // attrs[.strokeWidth] = -1
            }
            if style.fontStyle.contains(.outline) {
                attrs[.strokeWidth] = font.pointSize * 0.1
                attrs[.strokeColor] = style.color
                if style.fontStyle.contains(.underline) {
                    attrs[.underlineStyle] = NSUnderlineStyle.double.rawValue
                }
            }
            if style.fontStyle.contains(.underline) && !style.fontStyle.contains(.outline) {
                attrs[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
            if style.fontStyle.contains(.condensed) {
                let newFont = NSFontManager.shared.convert(font, toHaveTrait: .condensedFontMask)
                if NSFontManager.shared.traits(of: newFont).contains(.condensedFontMask) {
                    font = newFont
                } else {
                    let transform = AffineTransform(scaleByX: newFont.pointSize * 0.82, byY: newFont.pointSize)
                    font = NSFont(descriptor: font.fontDescriptor, textTransform: transform) ?? font
                }
            } else if style.fontStyle.contains(.extended) {
                let newFont = NSFontManager.shared.convert(font, toHaveTrait: .expandedFontMask)
                if NSFontManager.shared.traits(of: newFont).contains(.expandedFontMask) {
                    font = newFont
                } else {
                    let transform = AffineTransform(scaleByX: newFont.pointSize * 1.17, byY: newFont.pointSize)
                    font = NSFont(descriptor: font.fontDescriptor, textTransform: transform) ?? font
                }
            }
            attrs[.font] = font
            attrs[.stylStyle] = style
            return attrs
        }
    }

    public final class Run: DataHandleWriting {
        public var startOffset:     Int = 0                     /// Int32
        public var lineHeight:      Int = 0                     /// Int16
        public var fontAscent:      Int = 0                     /// Int16
        public var fontFamilyID:    ResID = 0                   /// Int16
        public var fontStyle:       MacFontStyle = .regular     /// UInt16 (little-endian; actually, UInt8 + UInt8 of padding)
        public var fontPointSize:   Int = 0                     /// UInt16
        public var rgbColor:        RGBColor                    /// 6

        // MARK: AUX
        public var style:           Style {
            return Style(fontFamilyID: fontFamilyID, fontStyle: fontStyle, fontPointSize: fontPointSize, color: rgbColor.color)
        }

        public var range:           NSRange = NSRange(location: 0, length: 0)

        public static var nodeLength: Int { 20 }

        public init(_ reader: BinaryDataReader, count textCount: Int) throws {
            startOffset = Int(try reader.read() as Int32)
            lineHeight = Int(try reader.read() as Int16)
            fontAscent = Int(try reader.read() as Int16)
            fontFamilyID = try reader.read()
            fontStyle = try reader.read(bigEndian: false)
            fontPointSize = Int(try reader.read() as UInt16)
            rgbColor = try RGBColor(reader)
            reader.pushSavedPosition()
            var endOffset = 0
            if let nextStartOffset: Int32 = try? reader.read() {
                endOffset = Int(nextStartOffset)
            } else {
                endOffset = textCount
            }
            reader.popPosition()
            range = NSMakeRange(startOffset, endOffset - startOffset)
        }

        public init(style: Style, range: NSRange) {
            self.startOffset = range.location
            if let font: NSFont = style.attrs[.font] as? NSFont {
                lineHeight = Int(font.ascender - font.descender + font.leading)
                fontAscent = Int(font.ascender)
            }
            self.fontFamilyID = style.fontFamilyID
            self.fontStyle = style.fontStyle
            self.fontPointSize = style.fontPointSize
            self.rgbColor = style.color.rgbColor
        }

        public func write(to handle: DataHandle, offset: Int? = 0) throws {
            assert(offset == 0)
            handle.write(Int32(startOffset))
            handle.write(Int16(lineHeight))
            handle.write(Int16(fontAscent))
            handle.write(ResID(fontFamilyID))
            handle.write(fontStyle, bigEndian: false)
            handle.write(UInt16(fontPointSize))
            try rgbColor.write(to: handle)
        }
    }
}

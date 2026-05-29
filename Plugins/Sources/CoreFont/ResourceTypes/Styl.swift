//
//  Styl.swift
//  CoreFont
//
//  Created by Mark Douma on 5/26/2026.
//

import Cocoa
import RFSupport
import SwiftUI

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
}

extension Styl {

    public final class Run: DataHandleWriting {
        public var startOffset:     Int = 0                     /// Int32
        public var lineHeight:      Int = 0                     /// Int16
        public var fontAscent:      Int = 0                     /// Int16
        public var fontFamilyID:    ResID = 0                   /// Int16
        public var style:           MacFontStyle = .regular     /// UInt16
        public var fontPointSize:   Int = 0                     /// UInt16
        public var rgbColor:        RGBColor                    /// 6

        // MARK: AUX
        public var color:           NSColor = .black
        public var font:            NSFont
        public var fontName:        String = ""
        public var range:           NSRange

        public var attrs:           [NSAttributedString.Key: Any]

        public static var nodeLength: Int { 20 }

        private static var briquetteIsSetup: Bool = false

        public init(_ reader: BinaryDataReader, count textCount: Int) throws {
            startOffset = Int(try reader.read() as Int32)
            lineHeight = Int(try reader.read() as Int16)
            fontAscent = Int(try reader.read() as Int16)
            fontFamilyID = try reader.read()
            style = try reader.read(bigEndian: false)
            fontPointSize = Int(try reader.read() as UInt16)
            rgbColor = try RGBColor(reader)
            color = rgbColor.color
            reader.pushSavedPosition()
            var endOffset = 0
            if let nextStartOffset: Int32 = try? reader.read() {
                endOffset = Int(nextStartOffset)
            } else {
                endOffset = textCount
            }
            reader.popPosition()
            range = NSMakeRange(startOffset, endOffset - startOffset)
            attrs = [:]
            attrs[.foregroundColor] = color
            if Self.briquetteIsSetup == false {
                do {
                    try FontActivationManager.default.activateFontFile(forResource: "Briquette", withExtension: "otf")
                } catch {
                    NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
                }
                Self.briquetteIsSetup = true
            }
            fontName = FOND.fontFamilyName(for: fontFamilyID)
            var font = NSFont(name: fontName, size: CGFloat(fontPointSize)) ?? NSFont.monospacedSystemFont(ofSize: CGFloat(fontPointSize), weight: .regular)
            if style.contains(.bold) {
                let newFont = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
                if NSFontManager.shared.traits(of: newFont).contains(.boldFontMask) {
                    font = newFont
                } else {
                    // FIXME: add synthetic bold effect

                }
            }
            if style.contains(.italic) {
                let newFont = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)
                if NSFontManager.shared.traits(of: newFont).contains(.italicFontMask) {
                    font = newFont
                } else {
                    let obliqueTransform = AffineTransform(m11: newFont.pointSize,
                                                           m12: tan(Angle(degrees: 0.0).radians),
                                                           m21: tan(Angle(degrees: 20.0).radians) * newFont.pointSize,
                                                           m22: newFont.pointSize, tX: 0, tY: 0)
                    font = NSFont(descriptor: font.fontDescriptor, textTransform: obliqueTransform) ?? font
                }
            }
            if style.contains(.outline) {
                
            }
            if style.contains(.underline) {
                attrs[.underlineStyle] = 1
            }
            if style.contains(.condensed) {
                let newFont = NSFontManager.shared.convert(font, toHaveTrait: .condensedFontMask)
                if NSFontManager.shared.traits(of: newFont).contains(.condensedFontMask) {
                    font = newFont
                } else {
                    // FIXME: add synthetic condensed effect
                    let transform = AffineTransform(scaleByX: newFont.pointSize * 0.917, byY: newFont.pointSize)
                    font = NSFont(descriptor: font.fontDescriptor, textTransform: transform) ?? font
                }
            } else if style.contains(.extended) {
                let newFont = NSFontManager.shared.convert(font, toHaveTrait: .expandedFontMask)
                if NSFontManager.shared.traits(of: newFont).contains(.expandedFontMask) {
                    font = newFont
                } else {
                    // FIXME: add synthetic expanded effect
                    let transform = AffineTransform(scaleByX: newFont.pointSize * 1.083, byY: newFont.pointSize)
                    font = NSFont(descriptor: font.fontDescriptor, textTransform: transform) ?? font
                }
            }
            self.font = font
            attrs[.font] = font
        }

        public func write(to handle: DataHandle, offset: Int? = 0) throws {
            assert(offset == 0)
            handle.write(Int32(startOffset))
            handle.write(Int16(lineHeight))
            handle.write(Int16(fontAscent))
            handle.write(ResID(fontFamilyID))
            handle.write(style, bigEndian: false)
            handle.write(UInt16(fontPointSize))
            try rgbColor.write(to: handle)
        }
    }
}

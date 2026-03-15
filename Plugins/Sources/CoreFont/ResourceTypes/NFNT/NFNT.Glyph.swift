//
//  NFNT.Glyph.swift
//  CoreFont
//
//  Created by Mark Douma on 3/12/2026.
//

import Cocoa

extension NFNT {

    public final class Glyph: NSObject {
        @objc dynamic public let charCode:        CharCode16
        @objc dynamic public let uv:              UVBMP

        @objc dynamic public let glyphRect:       NSRect
        @objc dynamic public let offset:          Int8
        @objc dynamic public let width:           Int8

        @objc dynamic public var pixelOffset:     Int16 {
            return Int16(glyphRect.origin.x)
        }

        @objc dynamic public lazy var character:  String = {  // glyph
            if isMissing { return "" }
            if self == .nullGlyph    { return NSLocalizedString("NULL", comment: "") }
            if uv == .undefined      { return "" }
            if let scalar = UnicodeScalar(uv) {
                return String(scalar)
            }
            return ""
        }()

        @objc dynamic public lazy var glyphName: String? = {
            if isMissing { return nil }
            return nfnt?.encoding.glyphName(for: self.charCode)
        }()

        public var isMissing: Bool {
            offset == -1 && width == -1 && glyphRect == .zero
        }

        public weak var nfnt:       NFNT?    /// nil for `.nullGlyph`

        public static let nullGlyph: Glyph = .init(glyphRect: .zero, offset: -1, width: -1, charCode: CharCode16.max, uv: .undefined, nfnt:nil)

        public init(glyphRect: NSRect, offset: Int8, width: Int8, charCode: CharCode16, uv: UVBMP, nfnt: NFNT?) {
            self.offset = offset
            self.width = width
            if self.offset == -1 && self.width == -1 {
                self.glyphRect = .zero
            } else {
                self.glyphRect = glyphRect
            }
            self.charCode = charCode
            self.uv = uv
            self.nfnt = nfnt
            super.init()
        }
    }
}

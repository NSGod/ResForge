//
//  NFNT.Glyph.swift
//  CoreFont
//
//  Created by Mark Douma on 3/12/2026.
//

import Cocoa

extension NFNT {

    public final class Glyph: NSObject {
        @objc dynamic public let charCode:        CharCode16    // 0 - 257-ish
        @objc dynamic public let uv:              UVBMP

        @objc dynamic public let glyphRect:       NSRect
        @objc dynamic public let offset:          Int8
        @objc dynamic public let width:           Int8

        @objc dynamic public var pixelOffset:     Int16 {
            return Int16(glyphRect.origin.x)
        }

        @objc dynamic public lazy var character:  String = {  // actual glyph (Character)
            if isMissing { return "" }
            if self == .nullGlyph    { return NSLocalizedString("NULL", comment: "") }
            if uv == .undefined      { return "" }
            if let scalar = UnicodeScalar(uv) {
                return String(scalar)
            }
            return ""
        }()

        @objc dynamic public lazy var glyphName: String = {
            if self == Self.nullGlyph {
                return ".null"
            } else if charCode == nfnt!.lastChar + 1 && uv == .undefined {
                return ".notdef"
            } else if charCode <= CharCode.max && uv != .undefined {
                return nfnt!.encoding.glyphName(for: CharCode(charCode)) ?? ""
            } else {
                return ""
            }
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

        public override func isEqual(_ object: Any?) -> Bool {
            guard let other = object as? Glyph else { return false }
            return charCode == other.charCode &&
            uv == other.uv && offset == other.offset && width == other.width
        }

        /// I believe this is what Swift does under the hood/bonnet, but
        /// better to make it explicitly clear
        public static func == (lhs: Glyph, rhs: Glyph) -> Bool {
            lhs.isEqual(rhs)
        }
    }
}

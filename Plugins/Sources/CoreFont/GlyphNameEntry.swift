//
//  GlyphNameEntry.swift
//  CoreFont
//
//  Created by Mark Douma on 1/1/2026.
//

import Foundation

// for display
extension MacEncoding {

    public final class GlyphNameEntry: NSObject, NSCopying, Comparable {
        @objc public let charCode:       CharCode
        @objc public let uv:             UVBMP
        @objc public let character:      String      // actual glyph
        @objc public let charName:       String      // UNICODE NAME
        @objc public let glyphName:      String      // Adobe Glyph List glyph name

        // for custom encodings
        public init(charCode: CharCode, glyphName: String) {
            self.charCode = charCode
            self.glyphName = glyphName
            let uVC = AdobeGlyphList.uv(forGlyphName: glyphName)
            if uVC != .undefined, let scalar = UnicodeScalar(uVC) {
                uv = uVC
                character = String(scalar)
                charName = scalar.properties.name ?? (character == "" ? NSLocalizedString("APPLE LOGO", comment: "") : "????")
            } else {
                if self.glyphName == "apple" {
                    uv = .appleLogo
                    character = ""
                    charName = NSLocalizedString("APPLE LOGO", comment: "")
                } else {
                    NSLog("\(type(of: self)).\(#function) *** glyphName == \(self.glyphName)")
                    uv = uVC
                    character = "????"
                    charName = "????"
                }
            }
            super.init()
        }

        public init(charCode: CharCode, uv: UVBMP, glyphName: String) {
            self.charCode = charCode
            self.uv = uv
            self.glyphName = glyphName
            if let scalar = UnicodeScalar(self.uv) {
                character = String(scalar)
                charName = scalar.properties.name ?? (character == "" ? NSLocalizedString("APPLE LOGO", comment: "") : "????")
            } else {
                if self.uv == .appleLogo {
                    character = ""
                    charName = NSLocalizedString("APPLE LOGO", comment: "")
                } else {
                    character = "????"
                    charName = "????"
                }
            }
            super.init()
        }

        public func copy(with zone: NSZone? = nil) -> Any {
            let copy = GlyphNameEntry(charCode: charCode, uv: uv, glyphName: glyphName)
            return copy
        }

        public static func entries(with encoding: MacEncoding) -> [GlyphNameEntry] {
            assert(!encoding.isCustomEncoding)
            var entries: [GlyphNameEntry] = []
            for i: CharCode in 0...CharCode.max {
                let uv = encoding.uv(for: i)
                if uv == .undefined { continue }
                let entry = GlyphNameEntry(charCode: i, uv: uv, glyphName: encoding.glyphName(for: uv) ?? "????")
                entries.append(entry)
            }
            entries.sort(by: <)
            return entries
        }

        public static func entries(with charCodesToGlyphNames: [CharCode: String]) -> [GlyphNameEntry] {
            var entries: [GlyphNameEntry] = []
            for (charCode, glyphName) in charCodesToGlyphNames {
                let entry = GlyphNameEntry(charCode: charCode, glyphName: glyphName)
                entries.append(entry)
            }
            entries.sort(by: <)
            return entries
        }

        public static func < (lhs: GlyphNameEntry, rhs: GlyphNameEntry) -> Bool {
            if lhs.charCode != rhs.charCode { return lhs.charCode < rhs.charCode }
            if lhs.uv != rhs.uv { return lhs.uv < rhs.uv }
            return lhs.glyphName.localizedStandardCompare(rhs.glyphName) == .orderedAscending
        }

        // FIXME: do we want all of these?
        public static func == (lhs: GlyphNameEntry, rhs: GlyphNameEntry) -> Bool {
            return lhs.charCode == rhs.charCode &&
            lhs.uv == rhs.uv &&
            lhs.glyphName == rhs.glyphName &&
            lhs.charName == rhs.charName &&
            lhs.character == rhs.character
        }
    }
}

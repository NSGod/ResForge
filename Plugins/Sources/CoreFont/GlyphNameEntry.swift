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
        @objc public let character:      String      // glyph
        @objc public let charName:       String      // UNICODE NAME
        @objc public let glyphName:      String      // Adobe Glyph List glyph name

        // for custom encoding
        public init(charCode: CharCode, glyphName: String) {
            self.charCode = charCode
            self.glyphName = glyphName
            self.uv = UVBMP(charCode) // FIXME: is this right? I don't think so
            character = ""
            charName = ""
            super.init()
        }

        public init(charCode: CharCode, uv: UVBMP, glyphName: String) {
            self.charCode = charCode
            self.uv = uv
            character = String(uv)  // FIXME: is this right?
            charName = UnicodeScalar(self.uv)?.properties.name ?? "???"
            self.glyphName = glyphName
            super.init()
        }

        public func copy(with zone: NSZone? = nil) -> Any {
            let copy = GlyphNameEntry(charCode: charCode, uv: uv, glyphName: glyphName)
            return copy
        }

        public class func entries(with encoding: MacEncoding) -> [GlyphNameEntry] {
            assert(!encoding.isCustomEncoding)
            var entries: [GlyphNameEntry] = []
            for i: CharCode in 0..<CharCode.max {
                let UV = encoding.uv(for: i)
                if UV == .undefined { continue }
                let entry = GlyphNameEntry(charCode: i, uv: UV, glyphName: encoding.glyphName(for: UV) ?? "???")
                entries.append(entry)
            }
            return entries
        }

        public class func entries(with charCodesToGlyphNames: [CharCode: String]) -> [GlyphNameEntry] {
            var entries: [GlyphNameEntry] = []
            for (charCode, glyphName) in charCodesToGlyphNames {
                let entry = GlyphNameEntry(charCode: charCode, glyphName: glyphName)
                entries.append(entry)
            }
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

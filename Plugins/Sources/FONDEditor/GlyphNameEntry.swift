//
//  GlyphNameEntry.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/1/2026.
//

import Foundation

// for display
class GlyphNameEntry: NSObject, Comparable {
    let charCode:       CharCode
    let uv:             UVBMP
    let character:      String      // glyph
    let charName:       String      // UNICODE NAME
    let glyphName:      String      // Adobe Glyph List glyph name


    init(charCode: CharCode, glyphName: String) {
        self.charCode = charCode
        self.glyphName = glyphName
        self.uv = UVBMP(charCode)
        character = ""
        charName = ""
        super.init()
    }

    init(charCode: CharCode, uv: UVBMP, glyphName: String) {
        self.charCode = charCode
        self.uv = uv
        character = String(uv)  // FIXME: is this right?
        charName = UnicodeScalar(self.uv)?.properties.name ?? "???"
        self.glyphName = glyphName
        super.init()
    }

    class func glyphNameEntries(with encoding: MacEncoding) -> [GlyphNameEntry] {
        assert(!encoding.isCustomEncoding)
        var entries: [GlyphNameEntry] = []
        for i: CharCode in 0..<CharCode.max {
            let UV = encoding.uv(for: i)
            if UV == UV_UNDEF { continue }
            let entry = GlyphNameEntry(charCode: i, uv: UV, glyphName: encoding.glyphName(for: UV) ?? "???")
            entries.append(entry)
        }
        return entries
    }

    class func glyphNameEntries(with charCodesToGlyphNames: [CharCode: String]) -> [GlyphNameEntry] {
        var entries: [GlyphNameEntry] = []
        for (charCode, glyphName) in charCodesToGlyphNames {
            let entry = GlyphNameEntry(charCode: charCode, glyphName: glyphName)
            entries.append(entry)
        }
        return entries
    }

    @objc func compare(_ other: GlyphNameEntry) -> ComparisonResult {
        let oUV = other.uv
        if charCode == other.charCode {
            if uv != 0 && oUV != 0 {
                if uv == oUV {
                    return glyphName.localizedStandardCompare(other.glyphName)
                } else {
                    return (uv as NSNumber).compare(oUV as NSNumber)
                }
            } else {
                return glyphName.localizedStandardCompare(other.glyphName)
            }
        } else {
            return (charCode as NSNumber).compare(other.charCode as NSNumber)
        }
    }

    static func < (lhs: GlyphNameEntry, rhs: GlyphNameEntry) -> Bool {
        return lhs.compare(rhs) == .orderedAscending
    }

    static func == (lhs: GlyphNameEntry, rhs: GlyphNameEntry) -> Bool {
        return lhs.compare(rhs) == .orderedSame
    }

}

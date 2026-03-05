//
//  GlyphMapping.swift
//  CoreFont
//
//  Created by Mark Douma on 2/24/2026.
//

import Foundation

// for display
extension FontTable_cmap {

    public final class GlyphMapping: FontTableNode {
        // FIXME: should this be UV, or??
        @objc dynamic public var charValue:     CharCode32 = 0
        @objc dynamic public var glyphID:       GlyphID32 = 0
        @objc dynamic public lazy var charName: String? = {     // UNICODE NAME
            var uv: UV = 0
            if subtable.encoding.platformID == .mac {
                guard let encoding = MacEncoding.encodingFor(scriptID: subtable.encoding.encodingID.macScriptID()!, languageID: subtable.languageID.macLanguageID()!) else {
                    return "<\(charValue)> (Unsupported Mac encoding)"
                }
                uv = UV(encoding.uv(for: CharCode(charValue)))
            } else {
                uv = charValue
            }
            if uv == 0 { return nil }
            return UnicodeScalar(uv)?.properties.name
        }()

        @objc dynamic public lazy var glyphName:     String? = {
            let glyphName = table.fontGlyphName(for: glyphID) ?? ""
            if subtable.encoding.platformID != .mac {
                if let adobeGlyphName = AdobeGlyphList.glyphName(for: UVBMP(charValue)) {
                    hasMappingConflict = !(adobeGlyphName == glyphName)
                }
            }
            return glyphName
        }()

        public private(set) var hasMappingConflict: Bool = false
        public private(set) var isUVS:              Bool = false
        public weak var subtable:                   Subtable!       // weak

        public init?(charValue: CharCode32, glyphID: GlyphID32, subtable: Subtable, table: FontTable) throws {
            try super.init(nil, table: table)
            if charValue > 0 && glyphID == 0 { return nil }
            self.charValue = charValue
            self.glyphID = glyphID
            self.subtable = subtable
        }
    }
}

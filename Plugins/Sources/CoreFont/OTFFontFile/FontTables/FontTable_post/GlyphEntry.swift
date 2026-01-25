//
//  GlyphEntry.swift
//  CoreFont
//
//  Created by Mark Douma on 1/21/2026.
//

import Foundation
import RFSupport

public extension FontTable_post {

    // for display
    @objc final class GlyphEntry: NSObject {
        public enum NameStyle {
            case a
            case aHex   // default
            case uniHex
        }

        @objc public var glyphID:     GlyphID = 0
        @objc public var glyphName:   String?   // CID use code only
        @objc public var code:        NSNumber?

        public init(glyphID: GlyphID, glyphName: String? = nil, code: NSNumber? = nil) {
            self.glyphID = glyphID
            self.glyphName = glyphName
            self.code = code
            if let codeValue: UVBMP = code?.uint16Value, glyphName == nil {
                if codeValue == .undefined {
                    self.glyphName = String(format:"glyph%05hu", glyphID)
                } else {
                    switch Self.defaultNameStyle {
                        case .a:
                            self.glyphName = String(format:"a%04hu", codeValue)
                        case .aHex:
                            self.glyphName = String(format:"a%04X", codeValue)
                        case .uniHex:
                            self.glyphName = String(format:"uni%04hX", codeValue)
                    }
                }
            }
        }

        public class var standardAppleGlyphEntries: [GlyphEntry] {
            var entries: [GlyphEntry] = []
            for i in 0..<appleStdGlyphNames.count {
                let entry = GlyphEntry(glyphID: GlyphID(i), glyphName: appleStdGlyphNames[i])
                entries.append(entry)
            }
            return entries
        }

        public static var defaultNameStyle: NameStyle = .aHex
    }
}

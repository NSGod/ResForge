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
    final class GlyphEntry: NSObject {
        public enum NameStyle {
            case a
            case aHex   // default
            case uniHex
        }

        @objc public var glyphID:       GlyphID
        @objc public var glyphName:     String      // CID-keyed use code-only
        public var code:                CharCode16? // represents charCode of 2-byte encoding; only for CID-keyed?

        public init(glyphID: GlyphID, glyphName: String? = nil, code: CharCode16? = nil) {
            self.glyphID = glyphID
            self.code = code
            if let code, glyphName == nil {
                if code == .undefined {
                    self.glyphName = String(format:"glyph%05hu", glyphID)
                } else {
                    switch Self.defaultNameStyle {
                        case .a:
                            self.glyphName = String(format:"a%04hu", code)
                        case .aHex:
                            self.glyphName = String(format:"a%04X", code)
                        case .uniHex:
                            self.glyphName = String(format:"uni%04hX", code)
                    }
                }
            } else if let glyphName {
                self.glyphName = glyphName
            } else {
                self.glyphName = String(format:"glyph%05hu", glyphID)
            }
        }

        public class var standardAppleGlyphEntries: [GlyphEntry] {
            return zip(appleStdGlyphNames.indices, appleStdGlyphNames).map { GlyphEntry(glyphID: GlyphID($0), glyphName: $1) }
        }

        public static var defaultNameStyle: NameStyle = .aHex
    }
}

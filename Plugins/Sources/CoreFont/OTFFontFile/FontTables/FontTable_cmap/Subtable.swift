//
//  Subtable.swift
//  CoreFont
//
//  Created by Mark Douma on 2/23/2026.
//

import Foundation
import RFSupport

extension FontTable_cmap {

    public class Subtable: FontTableNode {

        @objc public enum Format: UInt16 {
            case format0 = 0    /// not supported by Apple?
            case format2 = 2
            case format4 = 4    /// common
            case format6 = 6
            case format8 = 8    /// not suppported by Apple; rare, use discouraged
            case format10 = 10  /// not supported by Apple or Windows; rare, use discouraged
            case format12 = 12
            case format13 = 13  /// basically similar to 12; different interp. of `startGlyphID/glyphID` fields
            case format14 = 14
        }
        // MARK: -
        @objc public var format:        Format = .format0
        public var languageID:          LanguageID = .any           // one-based for Mac; should be 0 for all other platforms

        // MARK: - AUX:
        public weak var encoding:       Encoding!                   // weak
        public var charCodesToGlyphIDs: [CharCode32: Glyph32ID]?

        @objc dynamic public lazy var glyphMappings: [GlyphMapping] = {
            glyphMappings = []
            guard let sortedKeys = charCodesToGlyphIDs?.keys.sorted() else {
                return glyphMappings
            }
            do {
                for charCode in sortedKeys {
                    if let mapping = try GlyphMapping(charValue: charCode, glyphID: charCodesToGlyphIDs![charCode]!, subtable: self, table: table) {
                        glyphMappings.append(mapping)
                    }
                }
            } catch {
                NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
            }

            _hasLoadedGlyphMappings = true

            return glyphMappings
        }()

        var _hasLoadedGlyphMappings: Bool = false

        public required init(_ reader: BinaryDataReader?, offset: Int? = nil, encoding: Encoding, table: FontTable) throws {
            self.encoding = encoding
            try super.init(reader, offset: offset, table: table)
            if let reader {
                format = try reader.read()
            }
        }

        public func glyphID(for charCode: CharCode32) -> Glyph32ID {
            // NOTE: charCodesToGlyphIDs is created in concrete subclasses' init methods (except for UVSes).
            if charCodesToGlyphIDs == nil { return .undefined }
            guard let charCodesToGlyphIDs else { return .undefined }
            return charCodesToGlyphIDs[charCode] ?? .undefined
        }

        public static func `class`(for format: Format) -> Subtable.Type? {
            switch format {
                case .format0: return Subtable0.self
                case .format2: return Subtable2.self
                case .format4: return Subtable4.self
                case .format6: return Subtable6.self
                case .format8, .format10:
                    return nil
                case .format12:
                    return Subtable12.self
                case .format13:
                    return Subtable13.self
               case .format14:
                    return nil
            }
        }
    }
}

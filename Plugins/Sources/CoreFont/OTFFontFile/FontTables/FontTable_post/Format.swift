//
//  Format.swift
//  CoreFont
//
//  Created by Mark Douma on 1/21/2026.
//

import Foundation
import RFSupport

public extension FontTable_post {

    // abstract superclass
    class Format: FontTableNode {
        public var glyphNames:         [String] = []
        public var glyphIDsToEntries:  [Glyph32ID: GlyphEntry] = [:]

        // FIXME: move this up to ViewController_post level?
        // for display?
        @objc public var glyphEntries: [GlyphEntry] = []

        public required override init(_ reader: BinaryDataReader, offset: Int? = nil, table: FontTable) throws {
            try super.init(reader, offset: offset, table: table)
        }

        public func glyphName(for glyphID: Glyph32ID) -> String? {
            return glyphIDsToEntries[glyphID]?.glyphName
        }

        public static func `class`(for version: Version) -> Format.Type? {
            switch version {
                case .version1_0: return Format1_0.self
                case .version2_0: return Format2_0.self
                case .version2_5: return Format2_5.self
                case .version4_0: return Format4_0.self
                case .version3_0: fallthrough
                default:
                    return nil
            }
        }

        public override func write(to dataHandle: DataHandle) throws {
            // no op; prevent exception for Format1_0 which does no writing
        }
    }
}

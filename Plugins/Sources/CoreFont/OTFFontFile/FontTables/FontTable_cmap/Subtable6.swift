//
//  Subtable6.swift
//  CoreFont
//
//  Created by Mark Douma on 2/23/2026.
//

import Foundation
import RFSupport

extension FontTable_cmap {

    public final class Subtable6: Subtable {
        // public var format:           Format
        public var length:              UInt16 = 0
        // public var languageID:       LanguageID      // one-based for Mac; should be 0 for all other platforms

        public var firstCode:           UInt16 = 0
        public var entryCount:          UInt16 = 0
        public var glyphIDs:            [GlyphID] = []  // [entryCount]

        public override var nodeLength: UInt32 {
            Self.nodeLengthFor(glyphCount: UInt16(glyphIDs.count))
        }

        public required init(_ reader: BinaryDataReader?, offset: Int? = nil, encoding: FontTable_cmap.Encoding, table: FontTable) throws {
            try super.init(reader, offset: offset, encoding: encoding, table: table)
            if let reader {
                length = try reader.read()
                languageID = try LanguageID.languageIDWith(platformID: encoding.platformID, languageID: try reader.read())
                firstCode = try reader.read()
                entryCount = try reader.read()
                glyphIDs = try (0..<entryCount).map { _ in try reader.read() }
                var charCodesToGlyphIDs: [CharCode32: GlyphID32] = [:]
                for (i, glyphID) in glyphIDs.enumerated() {
                    charCodesToGlyphIDs[CharCode32(firstCode + UInt16(i))] = GlyphID32(glyphID)
                }
                self.charCodesToGlyphIDs = charCodesToGlyphIDs
            }
        }

        public static func nodeLengthFor(glyphCount: UInt16) -> UInt32 {
            var nodeLength = MemoryLayout<UInt16>.size * 5
            nodeLength += MemoryLayout<GlyphID>.size * Int(glyphCount)
            return UInt32(nodeLength)
        }

        public override func write(to dataHandle: DataHandle, offset: Int? = nil) throws {
            if let offset {
                dataHandle.pushSavedOffset()
                dataHandle.seek(to: offset)
                try super.write(to: dataHandle, offset: offset)
                dataHandle.write(length)
                dataHandle.write(languageID.rawValue)
                dataHandle.write(firstCode)
                dataHandle.write(entryCount)
                glyphIDs.forEach { dataHandle.write($0) }
                dataHandle.popAndSeekToSavedOffset()
            }
        }
    }
}

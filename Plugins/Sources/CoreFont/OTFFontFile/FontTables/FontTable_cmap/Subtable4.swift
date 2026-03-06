//
//  Subtable4.swift
//  CoreFont
//
//  Created by Mark Douma on 2/23/2026.
//

import Foundation
import RFSupport

extension FontTable_cmap {

    public final class Subtable4: Subtable {
        // public var format:           Format
        public var length:              UInt16 = 0
        // public var languageID:       LanguageID      // one-based for Mac; should be 0 for all other platforms

        public var segCountX2:          UInt16 = 0
        public var searchRange:         UInt16 = 0
        public var entrySelector:       UInt16 = 0
        public var rangeShift:          UInt16 = 0

        public var endCodes:            [UInt16] = []   // [segCount]

        public var reservedPadding:     UInt16 = 0      // adobe: "password"?

        public var startCodes:          [UInt16] = []   // [segCount]
        public var idDeltas:            [Int16] = []    // [segCount]
        public var idRangeOffsets:      [UInt16] = []   // [segCount]
        public var glyphIDs:            [GlyphID] = []  // [numGlyphs]

        public required init(_ reader: BinaryDataReader?, offset: Int? = nil, encoding: Encoding, table: FontTable) throws {
            try super.init(reader, offset: offset, encoding: encoding, table: table)
            if let reader {
                length = try reader.read()
                let langID: UInt16 = try reader.read()
                languageID = try LanguageID.languageIDWith(platformID: encoding.platformID, languageID: langID)
                segCountX2 = try reader.read()
                searchRange = try reader.read()
                entrySelector = try reader.read()
                rangeShift = try reader.read()
                let numSegments = segCountX2 / 2
                endCodes = try (0..<numSegments).map { _ in try reader.read() }
                reservedPadding = try reader.read()
                startCodes = try (0..<numSegments).map { _ in try reader.read() }
                idDeltas = try (0..<numSegments).map { _ in try reader.read() }
                idRangeOffsets = try (0..<numSegments).map { _ in try reader.read() }
                let glyphsLength = UInt32(length) - Self.nodeLengthFor(segmentCount: numSegments, glyphCount: 0)
                let numGlyphs = glyphsLength / UInt32(MemoryLayout<GlyphID>.size)
                glyphIDs = try (0..<numGlyphs).map { _ in try reader.read() }
                var charCodesToGlyphIDs: [CharCode32: GlyphID32] = [:]
                for i in 0..<Int(numSegments) {
                    let endCode = endCodes[i]
                    let startCode = startCodes[i]
                    let idDelta = idDeltas[i]
                    var idRangeOffset = idRangeOffsets[i]
                    let idRangeBytes = (numSegments - UInt16(i)) * 2
                    for code in UInt32(startCode)...UInt32(endCode) {
                        if idRangeOffset == 0xFFFF { /// Fontographer BUG
                            idRangeOffset = 0
                        }
                        var glyphID: GlyphID = 0
                        if idRangeOffset == 0 {
                            glyphID = GlyphID((Int(idDelta) + Int(code)) & 0x0FFFF)
                        } else {
                            glyphID = glyphIDs[Int(idRangeOffset - idRangeBytes) / 2 + Int(code) - Int(startCode)]
                        }
                        if code != 0xffff && glyphID != 0 {
                            if idRangeOffset != 0 {
                                glyphID = GlyphID(Int(glyphID) + Int(idDelta) & 0x0FFFF)
                            }
                            charCodesToGlyphIDs[CharCode32(code)] = GlyphID32(glyphID)
                        }
                    }
                }
                self.charCodesToGlyphIDs = charCodesToGlyphIDs
            }
        }
        
        public static func nodeLengthFor(segmentCount: UInt16, glyphCount: UInt16) -> UInt32 {
            var nodeLength = MemoryLayout<UInt16>.size * 8
            nodeLength += MemoryLayout<UInt16>.size * 4 * Int(segmentCount)
            nodeLength += MemoryLayout<GlyphID>.size * Int(glyphCount)
            return UInt32(nodeLength)
        }

        public override func write(to dataHandle: DataHandle, offset: Int? = nil) throws {
            guard let offset else { throw FontTableError.parseError("No offset") }
            dataHandle.pushSavedOffset()
            dataHandle.seek(to: offset)
            try super.write(to: dataHandle, offset: offset)
            dataHandle.write(length)
            dataHandle.write(languageID.rawValue)
            dataHandle.write(segCountX2)
            dataHandle.write(searchRange)
            dataHandle.write(entrySelector)
            dataHandle.write(rangeShift)
            endCodes.forEach { dataHandle.write($0) }
            dataHandle.write(reservedPadding)
            startCodes.forEach { dataHandle.write($0) }
            idDeltas.forEach { dataHandle.write($0) }
            idRangeOffsets.forEach { dataHandle.write($0) }
            glyphIDs.forEach { dataHandle.write($0) }
            dataHandle.popAndSeekToSavedOffset()
        }
    }
}

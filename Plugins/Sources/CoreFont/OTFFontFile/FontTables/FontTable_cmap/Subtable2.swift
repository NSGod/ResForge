//
//  Subtable2.swift
//  CoreFont
//
//  Created by Mark Douma on 2/23/2026.
//

import Foundation
import RFSupport

extension FontTable_cmap {
    
    public final class Subtable2: Subtable {
        // public var format:           Format
        public var length:              UInt16 = 0
        // public var languageID:       LanguageID      // one-based for Mac; should be 0 for all other platforms

        public var segmentKeys:         [UInt16] = []   // [256]
        public var segments:            [Segment] = []  // [_nSegments]
        public var glyphIDs:            [GlyphID] = []  // [_nGlyphs]

        private var _nSegments:         UInt16 = 0
        private var _nGlyphs:           UInt16 = 0

        public override var nodeLength: UInt32 {
            return Self.nodeLengthFor(segmentCount: UInt16(segments.count), glyphCount: UInt16(glyphIDs.count))
        }

        public required init(_ reader: BinaryDataReader?, offset: Int? = nil, encoding: Encoding, table: FontTable) throws {
            try super.init(reader, offset: offset, encoding: encoding, table: table)
            if let reader {
                length = try reader.read()
                languageID = try LanguageID.languageIDWith(platformID: encoding.platformID, languageID: try reader.read())
                var maxIndex: UInt16 = 0
                var theValue: UInt16 = 0
                for _ in 0..<256 {
                    theValue = try reader.read()
                    segmentKeys.append(theValue)
                    if (theValue / 8) > maxIndex { maxIndex = theValue / 8 }
                }
                _nSegments = maxIndex + 1
                segments = try (0..<_nSegments).map { _ in try Segment(reader, table: table) }
                _nGlyphs = UInt16((UInt32(length) - Self.nodeLengthFor(segmentCount: _nSegments, glyphCount: 0)) / 2)
                for _ in 0..<_nGlyphs {
                    glyphIDs.append(try reader.read())
                }
                /// construct the single byte mappings in a separate loop, since
                /// they take a slightly different logic than the double-byte mappings
                var charCodesToGlyphIDs: [CharCode32: GlyphID32] = [:]
                var seen: [Bool] = Array(repeating: true, count: 256)
                for i: UInt16 in 0..<256 {
                    let key = segmentKeys[Int(i)] / 8
                    if key == 0 { /* it's a single-byte char code */
                        let segment = segments[Int(key)]
                        if i >= segment.firstCode && i <= (segment.firstCode + segment.entryCount) {
                            let segDelta: UInt16 = (segment.idRangeOffset - ((_nSegments - key - 1) * UInt16(Segment.nodeLength) + 2)) / 2
                            var glyphID = glyphIDs[Int(segDelta + i - segment.firstCode)]
                            let code = i
                            if glyphID != 0 {
                                // glyphID = glyphID + UInt16(segment.idDelta) & 0x10000
                                glyphID = glyphID + UInt16(segment.idDelta)
                                charCodesToGlyphIDs[CharCode32(code)] = GlyphID32(glyphID)
                            }
                        }
                        seen[Int(i)] = true
                    } else {
                        seen[Int(i)] = false
                    }
                }
                for hi: UInt16 in 1..<256 {
                    if !seen[Int(hi)] {
                        let key = segmentKeys[Int(hi)] / 8
                        let segment = segments[Int(key)]
                        for i in 0..<segment.entryCount {
                            let segDelta = (segment.idRangeOffset - ((_nSegments - key - 1) * UInt16(Segment.nodeLength) + 2)) / 2
                            var glyphID = glyphIDs[Int(segDelta + i)]
                            let lo = segment.firstCode + UInt16(i)
                            let code = hi << 8 | (lo > 255 ? 0 : lo)
                            if glyphID != 0 {
                                glyphID = (glyphID + UInt16(segment.idDelta)) & 0x0ffff
                                charCodesToGlyphIDs[CharCode32(code)] = GlyphID32(glyphID)
                            }
                        }
                    }
                }
                self.charCodesToGlyphIDs = charCodesToGlyphIDs
            }
        }

        public static func nodeLengthFor(segmentCount: UInt16, glyphCount: UInt16) -> UInt32 {
            var nodeLength: UInt32 = UInt32(MemoryLayout<UInt16>.size * 3 + MemoryLayout<UInt16>.size * 256)
            nodeLength += Segment.nodeLength * UInt32(segmentCount)
            nodeLength += UInt32(glyphCount) * 2
            return nodeLength
        }

        public override func write(to handle: DataHandle, offset: Int? = nil) throws {
            assert(offset != nil)
            guard let offset else { throw FontTableError.writeError("No offset") }
            handle.pushSavedOffset()
            handle.seek(to: offset)
            try super.write(to: handle, offset: offset)
            handle.write(length)
            handle.write(languageID.rawValue)   // UInt16
            segmentKeys.forEach { handle.write($0) }
            try segments.forEach { try $0.write(to: handle) }
            glyphIDs.forEach { handle.write($0) }
            handle.popAndSeekToSavedOffset()
        }
    }
}

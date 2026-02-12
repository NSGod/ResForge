//
//  FontTable_hhea.swift
//  FontEditor
//
//  Created by Mark Douma on 1/25/2026.
//

import Foundation
import RFSupport

/// `REQUIRES`:
/// `DEPENDS ON`:
/// `DISPLAY DEPENDS ON`:

/* "The values in the minRightSidebearing, minLeftSideBearing and xMaxExtent
    should be computed using only glyphs that have contours. Glyphs with
    no contours should be ignored for the purposes of these calculations." */
/*
 The values for ascent, descent and lineGap represent the design intentions of the font's creator
 rather than any computed value, and individual glyphs may well exceed the the limits they represent.
 The values for the advanceWidthMax, minLeftSideBearing and minRightSideBearing are computed values
 and must be consistent with whatever values appear in the 'hmtx' table. These values are as their
 names imply, the actual maximum advance width for any glyph in the font, the minimum left side
 bearing for any glyph and the minimum right side bearing for any glyph. Similarly, the xMin, yMin,
 xMax, and yMax, fields in the 'head' represent the actual extrema for the glyphs in the font.

 */
final public class FontTable_hhea: FontTable {
    @objc public enum Version: Fixed {
        case default1_0 = 0x00010000
    }

    @objc dynamic public var version:               Version = .default1_0
    @objc dynamic public var ascender:              Int16 = 0   // design intention
    @objc dynamic public var descender:             Int16 = 0   // design intention
    @objc dynamic public var lineGap:               Int16 = 0   // design intention
    @objc dynamic public var advanceWidthMax:       UInt16 = 0  // calculated; must be consistent
    @objc dynamic public var minLeftSideBearing:    Int16 = 0   // calculated; must be consistent
    @objc dynamic public var minRightSideBearing:   Int16 = 0   // calculated; MIN (aWM - lsb - (xMax - xMin)); must be consistent
    @objc dynamic public var xMaxExtent:            UInt16 = 0  // MAX (lsb + (xMax - xMin))
    @objc dynamic public var caretSlopeRise:        Int16 = 0   // to calc slope of cursor; 1 for vertical
    @objc dynamic public var caretSlopeRun:         Int16 = 0   // 0 for vertical
    @objc dynamic public var caretOffset:           Int16 = 0

    @objc dynamic public var reserved0:             Int16 = 0
    @objc dynamic public var reserved1:             Int16 = 0
    @objc dynamic public var reserved2:             Int16 = 0
    @objc dynamic public var reserved3:             Int16 = 0

    @objc dynamic public var metricDataFormat:      Int16 = 0   // 0 for current format
    @objc dynamic public var numberOfHMetrics:      UInt16 = 0

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        let vers: Fixed = try reader.read()
        guard let version = Version(rawValue: vers) else {
            throw FontTableError.unknownVersion(String(format: "Unknown version %08X in 'hhea' table", vers))
        }
        self.version = version
        ascender = try reader.read()
        descender = try reader.read()
        lineGap = try reader.read()
        advanceWidthMax = try reader.read()
        minLeftSideBearing = try reader.read()
        minRightSideBearing = try reader.read()
        xMaxExtent = try reader.read()
        caretSlopeRise = try reader.read()
        caretSlopeRun = try reader.read()
        caretOffset = try reader.read()
        reserved0 = try reader.read()
        reserved1 = try reader.read()
        reserved2 = try reader.read()
        reserved3 = try reader.read()
        metricDataFormat = try reader.read()
        numberOfHMetrics = try reader.read()
    }

    override func prepareToWrite() throws {
        reserved0 = 0
        reserved1 = 0
        reserved2 = 0
        reserved3 = 0
        if let hmtxTable {
            /// we want `.metrics`, not optimized `.horizontalMetrics`
            numberOfHMetrics = UInt16(hmtxTable.metrics.count)
        }
    }

    override func write() throws {
        dataHandle.write(version)
        dataHandle.write(ascender)
        dataHandle.write(descender)
        dataHandle.write(lineGap)
        dataHandle.write(advanceWidthMax)
        dataHandle.write(minLeftSideBearing)
        dataHandle.write(minRightSideBearing)
        dataHandle.write(xMaxExtent)
        dataHandle.write(caretSlopeRise)
        dataHandle.write(caretSlopeRun)
        dataHandle.write(caretOffset)
        dataHandle.write(reserved0)
        dataHandle.write(reserved1)
        dataHandle.write(reserved2)
        dataHandle.write(reserved3)
        dataHandle.write(metricDataFormat)
        dataHandle.write(numberOfHMetrics)
    }
}

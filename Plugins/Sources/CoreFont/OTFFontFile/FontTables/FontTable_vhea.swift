//
//  FontTable_vhea.swift
//  CoreFont
//
//  Created by Mark Douma on 3/1/2026.
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
final public class FontTable_vhea: FontTable {
    @objc public enum Version: Fixed {
        case version1_0 = 0x00010000    // 65536
        case version1_1 = 0x00011000    // 69632
        /// In version 1.1, `ascent`, `descent`, and `lineGap` are renamed to their `vertTypo*` variant
    }

    @objc dynamic public var version:               Version = .version1_0
    @objc dynamic public var vertTypoAscender:      Int16 = 0   // ascent/vertTypoAscender
    @objc dynamic public var vertTypoDescender:     Int16 = 0   // descent/vertTypoDescender
    @objc dynamic public var vertTypoLineGap:       Int16 = 0   // lineGap(reserved; set to 0)/vertTypoLineGap
    @objc dynamic public var advanceHeightMax:      UInt16 = 0  // calculated; must be consistent
    @objc dynamic public var minTopSideBearing:     Int16 = 0   // calculated; must be consistent
    @objc dynamic public var minBottomSideBearing:  Int16 = 0   // calculated; must be consistent
    @objc dynamic public var yMaxExtent:            UInt16 = 0  // max(tsb + (yMax - yMin))
    @objc dynamic public var caretSlopeRise:        Int16 = 0
    @objc dynamic public var caretSlopeRun:         Int16 = 0   // 1 for nonslanted vertical fonts
    @objc dynamic public var caretOffset:           Int16 = 0   // 0 for nonslanted vertical fonts

    @objc dynamic public var reserved0:             Int16 = 0
    @objc dynamic public var reserved1:             Int16 = 0
    @objc dynamic public var reserved2:             Int16 = 0
    @objc dynamic public var reserved3:             Int16 = 0

    @objc dynamic public var metricDataFormat:      Int16 = 0   // 0 for current format
    @objc dynamic public var numberOfVMetrics:      UInt16 = 0

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        let vers: Fixed = try reader.read()
        guard let version = Version(rawValue: vers) else {
            throw FontTableError.unknownVersion(String(format: "Unknown version %08X in 'vhea' table", vers))
        }
        self.version = version
        vertTypoAscender = try reader.read()
        vertTypoDescender = try reader.read()
        vertTypoLineGap = try reader.read()
        advanceHeightMax = try reader.read()
        minTopSideBearing = try reader.read()
        minBottomSideBearing = try reader.read()
        yMaxExtent = try reader.read()
        caretSlopeRise = try reader.read()
        caretSlopeRun = try reader.read()
        caretOffset = try reader.read()
        reserved0 = try reader.read()
        reserved1 = try reader.read()
        reserved2 = try reader.read()
        reserved3 = try reader.read()
        metricDataFormat = try reader.read()
        numberOfVMetrics = try reader.read()
    }

    override func prepareToWrite() throws {
        reserved0 = 0
        reserved1 = 0
        reserved2 = 0
        reserved3 = 0
        if let vmtxTable {
            /// we want `.metrics`, not optimized/consolidated `.verticalMetrics`
            numberOfVMetrics = UInt16(vmtxTable.metrics.count)
        }
    }

    override func write() throws {
        dataHandle.write(version)
        dataHandle.write(vertTypoAscender)
        dataHandle.write(vertTypoDescender)
        dataHandle.write(vertTypoLineGap)
        dataHandle.write(advanceHeightMax)
        dataHandle.write(minTopSideBearing)
        dataHandle.write(minBottomSideBearing)
        dataHandle.write(yMaxExtent)
        dataHandle.write(caretSlopeRise)
        dataHandle.write(caretSlopeRun)
        dataHandle.write(caretOffset)
        dataHandle.write(reserved0)
        dataHandle.write(reserved1)
        dataHandle.write(reserved2)
        dataHandle.write(reserved3)
        dataHandle.write(metricDataFormat)
        dataHandle.write(numberOfVMetrics)
    }
}

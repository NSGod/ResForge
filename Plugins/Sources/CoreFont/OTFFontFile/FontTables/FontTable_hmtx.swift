//
//  FontTable_hmtx.swift
//  CoreFont
//
//  Created by Mark Douma on 1/26/2026.
//

import Foundation
import RFSupport

/// `REQUIRES`: `hhea`, `maxp`
/// `DEPENDS ON`:
/// `DISPLAY DEPENDS ON`: `post`

final public class FontTable_hmtx: FontTable {
    // abbreviated/optimized format as stored in data
    public var horizontalMetrics:       [HorizontalMetric] = []
    public var leftSideBearings:        [Int16] = []

    // MARK: AUX: display/working (expanded) format:
    @objc public var metrics:           [HorizontalMetric] = []

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        guard let numHMetrics: UInt16 = hheaTable?.numberOfHMetrics else {
            throw FontTableError.parseError("hmtx table: missing hhea.numberOfHMetrics")
        }
        // FIXME: !! allow for other methods to get the glyph count (see /afdko/c/spot/source/global.c for more info)
        let numGlyphs: UInt16 = UInt16(fontNumGlyphs)
        if numHMetrics > 1 {
            for i: GlyphID in 0..<numHMetrics {
                let hMetric = try HorizontalMetric(reader, glyphID: i, table: self)
                horizontalMetrics.append(hMetric)
                metrics.append(hMetric)
            }
            // If the num of metrics is less than the number of glyphs, replicate last metric for the rest of the glyphs
            let lastMetric = horizontalMetrics.last!
            for i in numHMetrics..<numGlyphs {
                let mCopy = lastMetric.copy() as! HorizontalMetric
                mCopy.glyphID = i
                metrics.append(mCopy)
            }
            // while the last metric may have been replicated to the rest of the glyphs, they may have different leftSideBearings
            let numLeftSideBearings: UInt16 = numGlyphs - numHMetrics
            if numLeftSideBearings > 0 {
                for i in 0..<numLeftSideBearings {
                    let leftSideBearing: Int16 = try reader.read()
                    leftSideBearings.append(leftSideBearing)
                    metrics[Int(i + numHMetrics)].leftSideBearing = leftSideBearing
                }
            }
        } else {
            // monospace font
            // monospace metrics: read the value and replicate for the rest
            let hMetric: HorizontalMetric = try HorizontalMetric(reader, glyphID: 0, table: self)
            horizontalMetrics.append(hMetric)
            metrics.append(hMetric)
            for i: GlyphID in 1..<numGlyphs {
                let mCopy = hMetric.copy() as! HorizontalMetric
                mCopy.glyphID = i
                metrics.append(mCopy)
            }
            // while the last metric may have been replicated to the rest of the glyphs, they may have different leftSideBearings
            let numLeftSideBearings: UInt16 = numGlyphs - numHMetrics
            if numLeftSideBearings > 0 {
                for i in 0..<numLeftSideBearings {
                    let leftSideBearing: Int16 = try reader.read()
                    leftSideBearings.append(leftSideBearing)
                    metrics[Int(i + numHMetrics)].leftSideBearing = leftSideBearing
                }
            }
        }
    }

    public func metric(for glyphID: GlyphID) -> HorizontalMetric? {
        if glyphID > metrics.count { return nil }
        return metrics[Int(glyphID)]
    }
}


final public class HorizontalMetric: FontTableNode {
    @objc public var advanceWidth:      UInt16 = 0
    @objc public var leftSideBearing:   Int16 = 0

    // MARK: for display
    @objc public var glyphID:           GlyphID = 0
    @objc lazy public var glyphName:    String? = {
        return table.fontGlyphName(for: Glyph32ID(glyphID))
    }()

    public init(_ reader: BinaryDataReader, glyphID: GlyphID, table: FontTable) throws {
        try super.init(reader, offset: nil, table: table)
        advanceWidth = try reader.read()
        leftSideBearing = try reader.read()
        self.glyphID = glyphID
    }

    @available(*, unavailable, message: "use init(_:glyphID:table:)")
    public override init(_ reader: BinaryDataReader, offset: Int? = nil, table: FontTable) throws {
        fatalError("init(_:offset:table:) not implemented")
    }

    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! HorizontalMetric
        copy.advanceWidth = advanceWidth
        copy.leftSideBearing = leftSideBearing
        copy.glyphID = glyphID
        return copy
    }
}

//
//  FontTable_vmtx.swift
//  CoreFont
//
//  Created by Mark Douma on 3/1/2026.
//

import Foundation
import RFSupport

/// `REQUIRES`: `vhea`, `maxp`
/// `DEPENDS ON`:
/// `DISPLAY DEPENDS ON`: `post`

public final class FontTable_vmtx: FontTable {
    // abbreviated/optimized format as stored in data
    public var verticalMetrics:         [VerticalMetric] = []
    public var topSideBearings:         [Int16] = []

    // MARK: AUX: display/working (expanded) format:
    @objc public var metrics:           [VerticalMetric] = []

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        guard let numVMetrics: UInt16 = vheaTable?.numberOfVMetrics else {
            throw FontTableError.parseError("vmtx table: missing vhea.numberOfVMetrics")
        }
        // FIXME: !! allow for other methods to get the glyph count (see /afdko/c/spot/source/global.c for more info)
        let numGlyphs: UInt16 = UInt16(fontNumGlyphs)
        if numVMetrics > 1 {
            for i: GlyphID in 0..<numVMetrics {
                let vMetric = try VerticalMetric(reader, glyphID: i, table: self)
                verticalMetrics.append(vMetric)
                metrics.append(vMetric)
            }
            // If the num of metrics is less than the number of glyphs, replicate last metric for the rest of the glyphs
            let lastMetric = verticalMetrics.last!
            for i in numVMetrics..<numGlyphs {
                let mCopy = lastMetric.copy() as! VerticalMetric
                mCopy.glyphID = i
                metrics.append(mCopy)
            }
            // while the last metric may have been replicated to the rest of the glyphs, they may have different topSideBearings
            let numTopSideBearings: UInt16 = numGlyphs - numVMetrics
            if numTopSideBearings > 0 {
                for i in 0..<numTopSideBearings {
                    let topSideBearing: Int16 = try reader.read()
                    topSideBearings.append(topSideBearing)
                    metrics[Int(i + numVMetrics)].topSideBearing = topSideBearing
                }
            }
        } else {
            // monospace font
            // monospace metrics: read the value and replicate for the rest
            let vMetric: VerticalMetric = try VerticalMetric(reader, glyphID: 0, table: self)
            verticalMetrics.append(vMetric)
            metrics.append(vMetric)
            for i: GlyphID in 1..<numGlyphs {
                let mCopy = vMetric.copy() as! VerticalMetric
                mCopy.glyphID = i
                metrics.append(mCopy)
            }
            // while the last metric may have been replicated to the rest of the glyphs, they may have different topSideBearings
            let numTopSideBearings: UInt16 = numGlyphs - numVMetrics
            if numTopSideBearings > 0 {
                for i in 0..<numTopSideBearings {
                    let topSideBearing: Int16 = try reader.read()
                    topSideBearings.append(topSideBearing)
                    metrics[Int(i + numVMetrics)].topSideBearing = topSideBearing
                }
            }
        }
    }

    public func metric(for glyphID: GlyphID) -> VerticalMetric? {
        if glyphID > metrics.count { return nil }
        return metrics[Int(glyphID)]
    }
}


public final class VerticalMetric: FontTableNode {
    @objc public var advanceHeight:     UInt16 = 0
    @objc public var topSideBearing:    Int16 = 0

    // MARK: for display
    @objc public var glyphID:           GlyphID = 0
    @objc lazy public var glyphName:    String? = {
        return table.fontGlyphName(for: Glyph32ID(glyphID))
    }()

    public init(_ reader: BinaryDataReader, glyphID: GlyphID, table: FontTable) throws {
        try super.init(reader, table: table)
        advanceHeight = try reader.read()
        topSideBearing = try reader.read()
        self.glyphID = glyphID
    }

    @available(*, unavailable, message: "use init(_:glyphID:table:)")
    public override init(_ reader: BinaryDataReader?, offset: Int? = nil, table: FontTable) throws {
        fatalError("init(_:offset:table:) not implemented")
    }

    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! VerticalMetric
        copy.advanceHeight = advanceHeight
        copy.topSideBearing = topSideBearing
        copy.glyphID = glyphID
        return copy
    }
}

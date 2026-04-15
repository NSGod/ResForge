//
//  CompoundGlyph.swift
//  CoreFont
//
//  Created by Mark Douma on 4/3/2026.
//

import Cocoa
import RFSupport

extension FontTable_glyf {

    public final class CompoundGlyph: Glyph {
        public var components:      [Component] = []

        public override var bezierPath: NSBezierPath? {
            var bezierPath: NSBezierPath?
            for component in components {
                if let bezierPath {
                    if let bpRep = component.bezierPath {
                        bezierPath.append(bpRep)
                    }
                } else {
                    bezierPath = component.bezierPath
                }
            }
            return bezierPath
        }

        public required init(_ reader: BinaryDataReader, location: FontTable_loca.GlyphLocation, glyphID: GlyphID, table: FontTable_glyf) throws {
            try super.init(reader, location: location, glyphID: glyphID, table: table)
            components = try Component.components(reader, compoundGlyph: self, table: table)
            isCompound = true
        }

        public override func awakeFromFont() {
            super.awakeFromFont()
            var allCoordinates: Coordinates? = nil
            for component in components {
                component.awakeFromFont(with: allCoordinates)
                if allCoordinates == nil {
                    allCoordinates = component.coordinates
                } else {
                    allCoordinates!.append(component.coordinates)
                }
            }
            coordinates = allCoordinates
            // FIXME: !! what about vertical metrics?
            for component in components {
                if component.flags.contains(.useMyMetrics) {
                    horizontalMetric = component.glyph?.horizontalMetric
                    verticalMetric = component.glyph?.verticalMetric
                    break
                }
            }
        }
    }
}

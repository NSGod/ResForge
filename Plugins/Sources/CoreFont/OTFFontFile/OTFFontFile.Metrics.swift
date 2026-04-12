//
//  OTFFontFile.Metrics.swift
//  CoreFont
//
//  Created by Mark Douma on 4/9/2026.
//

import Cocoa

extension OTFFontFile {

    public final class Metrics: OTFFontFileNode, UIFontMetrics {
        public var unitsPerEm:             UnitsPerEm = .trueTypeStandard
        public var boundingRectForFont:    NSRect = .zero
        public var ascender:               CGFloat = 0
        public var descender:              CGFloat = 0

        public var capHeight:              CGFloat = 0  /// `sCapHeight` or height of H
        public var xHeight:                CGFloat = 0  /// `sxHeight` or height of x

        public var leading:                CGFloat = 0  /// `hhea.lineGap` or `sTypoLineGap`; may be calculated
        public var lineHeight:             CGFloat = 0  /// ascender - descender + leading

        public var italicAngle:            CGFloat = 0

        public override init(fontFile: OTFFontFile) {
            try! super.init(fontFile: fontFile)
            if let headTable = fontFile.headTable {
                unitsPerEm = headTable.unitsPerEm
                boundingRectForFont = NSMakeRect(CGFloat(headTable.xMin), CGFloat(headTable.yMin), CGFloat(headTable.xMax - headTable.xMin), CGFloat(headTable.yMax - headTable.yMin))
            }
            if let hheaTable = fontFile.hheaTable {
                ascender = CGFloat(hheaTable.ascender)
                descender = CGFloat(hheaTable.descender)
                leading = CGFloat(hheaTable.lineGap)
            }
            if let os2Table = fontFile.os2Table {
                if ascender == 0 { ascender = CGFloat(os2Table.sTypoAscender) }
                if descender == 0 { descender = CGFloat(os2Table.sTypoDescender) }
                if os2Table.version >= .version2 {
                    capHeight = CGFloat(os2Table.sCapHeight)
                    xHeight = CGFloat(os2Table.sxHeight)
                }
            }
            if capHeight == 0 { capHeight = fontFile.glyph(forName: "H").yMax }
            if xHeight == 0 { xHeight = fontFile.glyph(forName: "x").yMax }
            if let postTable = fontFile.postTable {
                italicAngle = CGFloat(postTable.italicAngle)
            }
            
        }
    }


}

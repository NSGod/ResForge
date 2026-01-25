//
//  FontTable_post.swift
//  CoreFont
//
//  Created by Mark Douma on 1/21/2026.
//

import Foundation
import RFSupport

/// `REQUIRES`: `'maxp'`
/// `DEPENDS ON`:
/// `DISPLAY DEPENDS ON`:

final public class FontTable_post: FontTable {

    @objc public enum Version: Fixed {
        case version1_0     = 0x00010000  // TT & TTOT
        case version2_0     = 0x00020000  // TT & TTOT
        case version2_5     = 0x00025000  // TT & TTOT
        case version3_0     = 0x00030000  // TT, TTOT, & PS/CFF OTF fonts
        case version4_0     = 0x00040000  // for CID fonts?
    }

    @objc public var version:               Version = .version1_0
    @objc public var italicAngle:           Fixed = 0   // Italic angle in cntr-clockwise degrees from vert.
    @objc public var underlinePosition:     Int16 = 0   //
    @objc public var underlineThickness:    Int16 = 0   // should match thickness of U+005F LOW LINE & OS/2.yStrikeoutSize
    @objc public var isFixedPitch:          UInt32 = 0
    @objc public var minMemType42:          UInt32 = 0
    @objc public var maxMemType42:          UInt32 = 0
    @objc public var minMemType1:           UInt32 = 0
    @objc public var maxMemType1:           UInt32 = 0

    @objc public var format:                Format? // nil for .version3_0/format 3

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        version = Version(rawValue: try reader.read()) ?? .version1_0
        italicAngle = try reader.read()
        underlinePosition = try reader.read()
        underlineThickness = try reader.read()
        isFixedPitch = try reader.read()
        minMemType42 = try reader.read()
        maxMemType42 = try reader.read()
        minMemType1 = try reader.read()
        maxMemType1 = try reader.read()
        guard let tableClass: Format.Type = Format.class(for: version).self else {
            return
        }
        format = try tableClass.init(reader)
    }
}

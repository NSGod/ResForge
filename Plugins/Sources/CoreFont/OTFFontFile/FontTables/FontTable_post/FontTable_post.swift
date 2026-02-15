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

    @objc dynamic public var version:               Version = .version1_0
    @objc dynamic public var italicAngle:           Fixed = 0   // Italic angle in cntr-clockwise degrees from vert.
    @objc dynamic public var underlinePosition:     Int16 = 0   //
    @objc dynamic public var underlineThickness:    Int16 = 0   // should match thickness of U+005F LOW LINE & OS/2.yStrikeoutSize
    @objc dynamic public var isFixedPitch:          UInt32 = 0
    @objc dynamic public var minMemType42:          UInt32 = 0
    @objc dynamic public var maxMemType42:          UInt32 = 0
    @objc dynamic public var minMemType1:           UInt32 = 0
    @objc dynamic public var maxMemType1:           UInt32 = 0

    @objc dynamic public var format:                Format? // nil for .version3_0

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        let vers: Fixed = try reader.read()
        guard let version = Version(rawValue: vers) else {
            throw FontTableError.unknownVersion(String(format: "Unknown post table version: 0x%08X", vers))
        }
        self.version = version
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
        format = try tableClass.init(reader, table: self)
    }

    public func glyphName(for glyphID: Glyph32ID) -> String? {
        return format?.glyphName(for: glyphID)
    }

    override func write() throws {
        dataHandle.write(version)
        dataHandle.write(italicAngle)
        dataHandle.write(underlinePosition)
        dataHandle.write(underlineThickness)
        dataHandle.write(isFixedPitch)
        dataHandle.write(minMemType42)
        dataHandle.write(maxMemType42)
        dataHandle.write(minMemType1)
        dataHandle.write(maxMemType1)
        try format?.write(to: dataHandle)
    }
}

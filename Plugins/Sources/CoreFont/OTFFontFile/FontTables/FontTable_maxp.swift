//
//  FontTable_maxp.swift
//  CoreFont
//
//  Created by Mark Douma on 1/20/2026.
//

import Foundation
import RFSupport

/// `REQUIRES`:
/// `DEPENDS ON`:
/// `DISPLAY DEPENDS ON`: 

final public class FontTable_maxp: FontTable {
    @objc public enum Version: Fixed {
        case version0_5     = 0x00005000 // 20480   // for PS/CFF fonts
        case version1_0     = 0x00010000 // 65536   // for TT outlines
    }

    @objc dynamic public var version:               Version = .version0_5   // 0x00010000 (1.0, TT) or 0x00005000 (0.5, PS CFF))
    @objc dynamic public var numGlyphs:             UInt16 = 0  // number of glyphs in the font

    // only in .version1_0 for TT fonts:
    @objc dynamic public var maxPoints:             UInt16 = 0  // max points in non-compound glyph
    @objc dynamic public var maxContours:           UInt16 = 0  // max contours in non-compound glyph
    @objc dynamic public var maxCompositePoints:    UInt16 = 0  // max points in compound glyph
    @objc dynamic public var maxCompositeContours:  UInt16 = 0  // max contours in compound glyph
    @objc dynamic public var maxZones:              UInt16 = 0  // set to 2
    @objc dynamic public var maxTwilightPoints:     UInt16 = 0  // points used in Twilight Zone (Z0)
    @objc dynamic public var maxStorage:            UInt16 = 0  // number of Storage Area locations
    @objc dynamic public var maxFunctionDefs:       UInt16 = 0  // number of FDEFs
    @objc dynamic public var maxInstructionDefs:    UInt16 = 0  // number of IDEFs
    @objc dynamic public var maxStackElements:      UInt16 = 0  // max stack depth
    @objc dynamic public var maxSizeOfInstructions: UInt16 = 0  // byte count for glyph instructions
    @objc dynamic public var maxComponentElements:  UInt16 = 0  // number of glyphs referenced at top level
    @objc dynamic public var maxComponentDepth:     UInt16 = 0  // levels of recursion; set to 0 if font only has simple glyphs; max is 16;
                                                                // set to 1 if all compound glyphs are simple

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        let vers: Fixed = try reader.read()
        guard let version = Version(rawValue: vers) else {
            throw FontTableError.unknownVersion(String(format:"Unknown 'maxp' table version: 0x%08X", vers))
        }
        self.version = version
        numGlyphs = try reader.read()
        if version == .version1_0 {
            maxPoints = try reader.read()
            maxContours = try reader.read()
            maxCompositePoints = try reader.read()
            maxCompositeContours = try reader.read()
            maxZones = try reader.read()
            maxTwilightPoints = try reader.read()
            maxStorage = try reader.read()
            maxFunctionDefs = try reader.read()
            maxInstructionDefs = try reader.read()
            maxStackElements = try reader.read()
            maxSizeOfInstructions = try reader.read()
            maxComponentElements = try reader.read()
            maxComponentDepth = try reader.read()
        }
    }

    override func write() throws {
        dataHandle.write(version)
        dataHandle.write(numGlyphs)
        if version == .version1_0 {
            dataHandle.write(maxPoints)
            dataHandle.write(maxContours)
            dataHandle.write(maxCompositePoints)
            dataHandle.write(maxCompositeContours)
            dataHandle.write(maxZones)
            dataHandle.write(maxTwilightPoints)
            dataHandle.write(maxStorage)
            dataHandle.write(maxFunctionDefs)
            dataHandle.write(maxInstructionDefs)
            dataHandle.write(maxStackElements)
            dataHandle.write(maxSizeOfInstructions)
            dataHandle.write(maxComponentElements)
            dataHandle.write(maxComponentDepth)
        }
    }
}

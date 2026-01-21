//
//  FontTable_head.swift
//  CoreFont
//
//  Created by Mark Douma on 1/18/2026.
//

import Foundation
import RFSupport

/// `REQUIRES`: no other tables
/// `DEPENDS ON`: no other tables
/// `DISPLAY DEPENDS ON`: no other tables

final public class FontTable_head: FontTable {

    @objc public enum Version: Fixed {
        case default1_0 = 0x00010000
    }

    public struct Flags: OptionSet {
        public let rawValue: UInt16
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
        public static let baselineIsY0:                    Flags = Flags(rawValue: 1 << 0)
        public static let xOfLeftmostBlackIsLSB:           Flags = Flags(rawValue: 1 << 1)
        public static let instructionsDependOnPointSize:   Flags = Flags(rawValue: 1 << 2)
        public static let useIntegerScaling:               Flags = Flags(rawValue: 1 << 3)
        public static let hintsMayAlterAdvanceWidth:       Flags = Flags(rawValue: 1 << 4)
        public static let verticalBaselineIsX0:            Flags = Flags(rawValue: 1 << 5)
        public static let bit6:                            Flags = Flags(rawValue: 1 << 6)
        public static let fontRequiresLayout:              Flags = Flags(rawValue: 1 << 7)
        public static let fontHasDefaultMorts:             Flags = Flags(rawValue: 1 << 8)
        public static let fontCanReorder:                  Flags = Flags(rawValue: 1 << 9)
        public static let fontCanRearrange:                Flags = Flags(rawValue: 1 << 10)
        public static let fontDataIsLossless:              Flags = Flags(rawValue: 1 << 11)
        public static let fontIsConverted:                 Flags = Flags(rawValue: 1 << 12)
        public static let optimizedForClearType:           Flags = Flags(rawValue: 1 << 13)
        public static let lastResortFont:                  Flags = Flags(rawValue: 1 << 14)
        public static let bit15:                           Flags = Flags(rawValue: 1 << 15)
    }

    @objc public enum FontDirectionHint: Int16 {
        case leftToRightWithNeutrals        = -2
        case leftToRight                    = -1
        case fullyMixedLeftToRight          = 0
        case rightToLeft                    = 1
        case rightToLeftWithNeutrals        = 2
    }

    public static let checksumConstant:         UInt32 = 0xB1B0AFBA
    public static let checksumAdjustmentOffset: UInt32 = 8 // sizeof(UInt32) * 2
    public static let magicNumber:              UInt32 = 0x5F0F3CF5

    // MARK: -
    @objc public var version:               Version = .default1_0   // UInt32; 0x00010000
    @objc public var fontRevision:          Fixed = 0               // SInt32
    @objc public var checkSumAdjustment:    UInt32 = 0
    @objc public var magicNumber:           UInt32 = FontTable_head.magicNumber   // set to 0x5F0F3CF5
    public var flags:                       Flags = []
    public var unitsPerEm:                  UnitsPerEm = .custom(0) // UInt16; from 16-16384; if TT outlines, power-of-2 is recommended
    @objc public var created:               Int64 = 0               // num seconds since midnight Jan 1, 1904 in GMT/UTC time zone
    @objc public var modified:              Int64 = 0               // num seconds since midnight Jan 1, 1904 in GMT/UTC time zone
    @objc public var xMin:                  Int16 = 0               // for all glyphs (only those w/ contours) bounding boxes
    @objc public var yMin:                  Int16 = 0               // for all glyphs (only those w/ contours) bounding boxes
    @objc public var xMax:                  Int16 = 0               // for all glyphs (only those w/ contours) bounding boxes
    @objc public var yMax:                  Int16 = 0               // for all glyphs (only those w/ contours) bounding boxes
    public var macStyle:                    MacFontStyle = []       // UInt16; should be synced w/ OS/2 fsSelection bits
    @objc public var lowestRecPPEM:         UInt16 = 0              // smallest readable size in px
    @objc public var fontDirectionHint:     FontDirectionHint = .fullyMixedLeftToRight // deprecated? (set to 2)
    @objc public var indexToLocFormat:      Int16 = 0               // 0 for short offsets, 2 for long
    @objc public var glyphDataFormat:       Int16 = 0               // 0 for current format

    @objc public var createdDate:           Date!
    @objc public var modifiedDate:          Date!

    @objc public var objcFlags:             Flags.RawValue = 0 {
        didSet { flags = Flags(rawValue: objcFlags) }
    }
    @objc public var objcMacStyle:          MacFontStyle.RawValue = 0 {
        didSet { macStyle = MacFontStyle(rawValue: objcMacStyle) }
    }
    @objc public var objcUnitsPerEm:        UInt16 = 0 {
        didSet {
            unitsPerEm = UnitsPerEm(rawValue: objcUnitsPerEm)
        }
    }

    public required init(with tableData: Data, tag: TableTag) throws {
        try super.init(with: tableData, tag: tag)
        version = Version(rawValue: try reader.read()) ?? .default1_0
        fontRevision = try reader.read()
        checkSumAdjustment = try reader.read()
        magicNumber = try reader.read()
        flags = Flags(rawValue: try reader.read())
        objcFlags = flags.rawValue
        unitsPerEm = UnitsPerEm(rawValue: try reader.read())
        created = try reader.read()
        modified = try reader.read()
        xMin = try reader.read()
        yMin = try reader.read()
        xMax = try reader.read()
        yMax = try reader.read()
        macStyle = MacFontStyle(rawValue: try reader.read())
        lowestRecPPEM = try reader.read()
        fontDirectionHint = FontDirectionHint(rawValue: try reader.read()) ?? .rightToLeftWithNeutrals
        indexToLocFormat = try reader.read()
        glyphDataFormat = try reader.read()
        createdDate = Date(secondsSince1904: created)
        modifiedDate = Date(secondsSince1904: modified)
    }
}

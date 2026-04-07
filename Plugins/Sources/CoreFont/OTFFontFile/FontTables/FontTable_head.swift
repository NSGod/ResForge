//
//  FontTable_head.swift
//  CoreFont
//
//  Created by Mark Douma on 1/18/2026.
//

import Foundation
import RFSupport

/// `REQUIRES`:
/// `DEPENDS ON`:
/// `DISPLAY DEPENDS ON`:

public class FontTable_head: FontTable {

    @objc public enum Version: Fixed {
        case default1_0 = 0x00010000
    }

    public struct Flags: OptionSet {
        public let rawValue: UInt16
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
        public static let horizontalBaselineIsY0:          Flags = Flags(rawValue: 1 << 0)  /// Horiz. baseline for font is at y=0
        public static let xOfLeftmostBlackIsLSB:           Flags = Flags(rawValue: 1 << 1)  /// x pos of left-most black bit is LSB
        public static let instructionsDependOnPointSize:   Flags = Flags(rawValue: 1 << 2)  /// scaled pt size `(12 * 2)` ≠ actual point size (24)
        public static let useIntegerScaling:               Flags = Flags(rawValue: 1 << 3)  /// use integer scaling instead of fractional
        public static let hintsMayAlterAdvanceWidth:       Flags = Flags(rawValue: 1 << 4)  /// (MS) advance widths may not scale linearly
        public static let verticalBaselineIsX0:            Flags = Flags(rawValue: 1 << 5)  /// Vert. baseline for font is at x=0; Apple
        public static let reserved6:                       Flags = Flags(rawValue: 1 << 6)  /// reserved; set to 0
        public static let fontRequiresLayout:              Flags = Flags(rawValue: 1 << 7)  /// requires layout for correct linguistic rendering (Arabic fonts); `legacy Apple`
        public static let fontHasDefaultMorts:             Flags = Flags(rawValue: 1 << 8)  /// has a `mort` effect designated as happening by default; `legacy Apple`
        public static let fontCanReorder:                  Flags = Flags(rawValue: 1 << 9)  /// set if font contains strong R-to-L glyphs; `legacy Apple`
        public static let fontCanRearrange:                Flags = Flags(rawValue: 1 << 10) /// font contains Indic-style rearrangement effects; `legacy Apple`
        public static let fontDataIsLossless:              Flags = Flags(rawValue: 1 << 11)
        public static let fontIsConverted:                 Flags = Flags(rawValue: 1 << 12)
        public static let optimizedForClearType:           Flags = Flags(rawValue: 1 << 13) /// (MS)
        public static let lastResortFont:                  Flags = Flags(rawValue: 1 << 14) /// set if glyphs are generic symbols for code page ranges
        public static let reserved15:                      Flags = Flags(rawValue: 1 << 15) /// reserved; set to 0
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
    @objc dynamic public var version:               Version = .default1_0   // Int32; 0x00010000
    @objc dynamic public var fontRevision:          Fixed = 0               // Int32
    @objc dynamic public var checkSumAdjustment:    UInt32 = 0
    @objc dynamic public var magicNumber:           UInt32 = FontTable_head.magicNumber   // set to 0x5F0F3CF5
    public var flags:                               Flags = []
    public var unitsPerEm:                          UnitsPerEm = .custom(0) // UInt16; from 16-16384; if TT outlines, power-of-2 is recommended
    @objc dynamic public var created:               Int64 = 0               // num seconds since midnight Jan 1, 1904 in GMT/UTC time zone
    @objc dynamic public var modified:              Int64 = 0               // num seconds since midnight Jan 1, 1904 in GMT/UTC time zone
    @objc dynamic public var xMin:                  Int16 = 0               // for all glyphs (only those w/ contours) bounding boxes
    @objc dynamic public var yMin:                  Int16 = 0               // for all glyphs (only those w/ contours) bounding boxes
    @objc dynamic public var xMax:                  Int16 = 0               // for all glyphs (only those w/ contours) bounding boxes
    @objc dynamic public var yMax:                  Int16 = 0               // for all glyphs (only those w/ contours) bounding boxes
    public var macStyle:                            MacFontStyle = []       // UInt16; should be synced w/ OS/2 fsSelection bits
    @objc dynamic public var lowestRecPPEM:         UInt16 = 0              // smallest readable size in px
    @objc dynamic public var fontDirectionHint:     FontDirectionHint = .fullyMixedLeftToRight // deprecated? (set to 2)
    @objc dynamic public var indexToLocFormat:      LocaOffsetFormat = .short   // 0 for short offsets, 1 for long
    @objc dynamic public var glyphDataFormat:       Int16 = 0               // 0 for current format

    public override var calculatedChecksum: UInt32 {
        /// we're different in that we need to set `checksumAdjustment`
        /// to 0 before calculating the checksum
        NSLog("\(type(of: self)).\(#function)")
        let dataHandle = DataHandle()
        do {
            try write(to: dataHandle, updating: nil)
            let tableLongs: [UInt32] = dataHandle.data.withUnsafeBytes {
                $0.bindMemory(to: UInt32.self).map(\.bigEndian)
            }
            var calcChecksum: UInt32 = 0
            tableLongs.forEach { calcChecksum &+= $0 }
            return calcChecksum
        } catch {
            NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
        }
        return 0
    }

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        let vers: Fixed = try reader.read()
        guard let version = Version(rawValue: vers) else {
            throw FontTableError.unknownVersion(String(format: "Unknown 'head' table version: 0x%08X", vers))
        }
        self.version = version
        fontRevision = try reader.read()
        checkSumAdjustment = try reader.read()
        magicNumber = try reader.read()
        flags = Flags(rawValue: try reader.read())
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
    }

    override func prepareToWrite() throws {
        magicNumber = Self.magicNumber
    }

    override func write(to extDataHandle: DataHandle, updating entry: OTFsfntDirectoryEntry?) throws {
        let before: UInt32 = UInt32(extDataHandle.currentOffset)
        extDataHandle.write(version)
        extDataHandle.write(fontRevision)
        extDataHandle.write(0 as UInt32) // leave checksum adjustment blank for now
        extDataHandle.write(magicNumber)
        extDataHandle.write(flags)
        extDataHandle.write(unitsPerEm.rawValue)
        extDataHandle.write(created)
        extDataHandle.write(modified)
        extDataHandle.write(xMin)
        extDataHandle.write(yMin)
        extDataHandle.write(xMax)
        extDataHandle.write(yMax)
        extDataHandle.write(macStyle)
        extDataHandle.write(lowestRecPPEM)
        extDataHandle.write(fontDirectionHint)
        extDataHandle.write(indexToLocFormat)
        extDataHandle.write(glyphDataFormat)
        let after: UInt32 = UInt32(extDataHandle.currentOffset)
        let padBytesLength = (~(after & 0x3) &+ 1) & 0x3
        if padBytesLength > 0 { extDataHandle.writeData(Data(count: Int(padBytesLength))) }
        entry?.tableTag = tableTag
        entry?.table = self
        entry?.offset = before
        entry?.length = after - before
    }
}

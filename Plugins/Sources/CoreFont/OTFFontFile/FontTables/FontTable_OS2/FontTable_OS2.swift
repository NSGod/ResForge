//
//  FontTable_OS2.swift
//  CoreFont
//
//  Created by Mark Douma on 1/25/2026.
//

import Foundation
import RFSupport

/// `REQUIRES`:
/// `DEPENDS ON`:
/// `DISPLAY DEPENDS ON`:

final public class FontTable_OS2: FontTable {

    @objc public enum Version: UInt16, Comparable {
        case version0           = 0
        case version1           = 1
        case version2           = 2
        case version3           = 3
        case version4           = 4
        case version5           = 5
        case none               = 0xffff

        public var length: Int {
            switch self {
                case .version0:
                    return 78
                case .version1:
                    return 86
                case .version2, .version3, .version4:
                    return 96
                case .version5:
                    return 100
                case .none:
                    return 0
            }
        }

        public static func version(forLength length: Int) -> Version {
            switch length {
                case 78: return .version0
                case 86: return .version1
                case 96: return .version2
                case 100: return .version5
                default: return .version0
            }
        }

        public static func < (lhs: Version, rhs: Version) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }

        public static func == (lhs: Version, rhs: Version) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }

    @objc public var version:                   Version = .version0
    @objc public var xAvgCharWidth:             Int16 = 0
    public var usWeightClass:                   Weight = .normal
    @objc public var usWidthClass:              Width = .normal
    public var fsType:                          FontType = .installableEmbedding
    @objc public var ySubscriptXSize:           Int16 = 0
    @objc public var ySubscriptYSize:           Int16 = 0
    @objc public var ySubscriptXOffset:         Int16 = 0
    @objc public var ySubscriptYOffset:         Int16 = 0
    @objc public var ySuperscriptXSize:         Int16 = 0
    @objc public var ySuperscriptYSize:         Int16 = 0
    @objc public var ySuperscriptXOffset:       Int16 = 0
    @objc public var ySuperscriptYOffset:       Int16 = 0
    @objc public var yStrikeoutSize:            Int16 = 0
    @objc public var yStrikeoutPosition:        Int16 = 0
    @objc public var sFamilyClass:              Int16 = 0 /// IBM font family class (high byte) & subclass (low byte)
    @objc public var panose:                    Panose!
                                                                  /// - Note: all 128 bits are there in all versions
                                                                  ///    but only fully utilized in ver 1+
    public var ulUnicodeRange1:                 UnicodeMask1 = [] /// UInt32; ver 0: bits 0-31
    public var ulUnicodeRange2:                 UnicodeMask2 = [] /// UInt32; ver 1+: bits 32-63
    public var ulUnicodeRange3:                 UnicodeMask3 = [] /// UInt32; ver 1+: bits 64-95
    public var ulUnicodeRange4:                 UnicodeMask4 = [] /// UInt32; ver 1+: bits 96-127
                                                                  ///
    @objc public var vendorID:                  Tag = 0

    public var fsSelection:                     Selection = .none
    @objc public var usFirstCharIndex:          UVBMP = 0
    @objc public var usLastCharIndex:           UVBMP = 0
    @objc public var sTypoAscender:             Int16 = 0   // newer
    @objc public var sTypoDescender:            Int16 = 0   // newer
    @objc public var sTypoLineGap:              Int16 = 0   // newer; typical values average 7-10% units per em
    @objc public var usWinAscent:               UInt16 = 0  // yMax in Windows or clipping can occur
    @objc public var usWinDescent:              UInt16 = 0  // -yMin in Windows or clipping can occur

    public var ulCodePageRange1:                CodePageMask1 = [] // ver 1+
    public var ulCodePageRange2:                CodePageMask2 = [] // ver 1+

    @objc public var sxHeight:                  Int16 = 0   // ver 2+
    @objc public var sCapHeight:                Int16 = 0   // ver 2+
    @objc public var usDefaultChar:             UVBMP = 0   // ver 2+
    @objc public var usBreakChar:               UVBMP = 0   // ver 2+
    @objc public var usMaxContext:              UInt16 = 0  // ver 2+ max lookahead context: e.g. for ffl ligature, it'd be 2

    @objc public var usLowerOpticalPointSize:   UInt16 = 0  // ver 5+
    @objc public var usUpperOpticalPointSize:   UInt16 = 0  // ver 5+

    @objc public var objcWeightClass:           Weight.RawValue = 0

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        let vers: UInt16 = try reader.read()
        guard let versn = Version(rawValue: vers) else {
            throw FontTableError.unknownVersion(String(format: "Unknown 'OS/2' table version: 0x%04X", vers))
        }
        self.version = versn
        xAvgCharWidth = try reader.read()
        usWeightClass = Weight(rawValue: try reader.read())
        let usWidth: UInt16 = try reader.read()
        guard let usWidthCls = Width(rawValue: usWidth) else {
            throw FontTableError.parseError("Unknown width class \(usWidth) in 'OS/2' table")
        }
        usWidthClass = usWidthCls
        fsType = FontType(rawValue: try reader.read())
        ySubscriptXSize = try reader.read()
        ySubscriptYSize = try reader.read()
        ySubscriptXOffset = try reader.read()
        ySubscriptYOffset = try reader.read()
        ySuperscriptXSize = try reader.read()
        ySuperscriptYSize = try reader.read()
        ySuperscriptXOffset = try reader.read()
        ySuperscriptYOffset = try reader.read()
        yStrikeoutSize = try reader.read()
        yStrikeoutPosition = try reader.read()
        sFamilyClass = try reader.read()
        panose = try Panose(reader, table: self)
        ulUnicodeRange1 = UnicodeMask1(rawValue: try reader.read())
        ulUnicodeRange2 = UnicodeMask2(rawValue: try reader.read())
        ulUnicodeRange3 = UnicodeMask3(rawValue: try reader.read())
        ulUnicodeRange4 = UnicodeMask4(rawValue: try reader.read())
        vendorID = try reader.read()
        fsSelection = Selection(rawValue: try reader.read())
        usFirstCharIndex = try reader.read()
        usLastCharIndex = try reader.read()
        sTypoAscender = try reader.read()
        sTypoDescender = try reader.read()
        sTypoLineGap = try reader.read()
        usWinAscent = try reader.read()
        usWinDescent = try reader.read()
        /// Try to handle insufficient data for specified version gracefully.
        /// If there's not enough data, see if we can knock back the version
        /// number to match the amount of data found
        var targetVersion = Version.version0
        do {
            if version >= .version1 {
                ulCodePageRange1 = CodePageMask1(rawValue: try reader.read())
                ulCodePageRange2 = CodePageMask2(rawValue: try reader.read())
                targetVersion = .version1
                if version >= .version2 {
                    sxHeight = try reader.read()
                    sCapHeight = try reader.read()
                    usDefaultChar = try reader.read()
                    usBreakChar = try reader.read()
                    usMaxContext = try reader.read()
                    targetVersion = .version2
                    if version >= .version5 {
                        usLowerOpticalPointSize = try reader.read()
                        usUpperOpticalPointSize = try reader.read()
                    }
                }
            }
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** WARNING: Failed to read all expected fields for FontTable_OS2.version\(version.rawValue), falling back to version \(targetVersion); byte count: \(tableData.count)")
            version = targetVersion
        }
    }

    override func write() throws {
        dataHandle.write(version)
        dataHandle.write(xAvgCharWidth)
        dataHandle.write(usWeightClass.rawValue)
        dataHandle.write(usWidthClass)
        dataHandle.write(fsType)
        dataHandle.write(ySubscriptXSize)
        dataHandle.write(ySubscriptYSize)
        dataHandle.write(ySubscriptXOffset)
        dataHandle.write(ySubscriptYOffset)
        dataHandle.write(ySuperscriptXSize)
        dataHandle.write(ySuperscriptYSize)
        dataHandle.write(ySuperscriptXOffset)
        dataHandle.write(ySuperscriptYOffset)
        dataHandle.write(yStrikeoutSize)
        dataHandle.write(yStrikeoutPosition)
        dataHandle.write(sFamilyClass)
        try panose.write(to: dataHandle)
        dataHandle.write(ulUnicodeRange1)
        dataHandle.write(ulUnicodeRange2)
        dataHandle.write(ulUnicodeRange3)
        dataHandle.write(ulUnicodeRange4)
        dataHandle.write(vendorID)
        dataHandle.write(fsSelection)
        dataHandle.write(usFirstCharIndex)
        dataHandle.write(usLastCharIndex)
        dataHandle.write(sTypoAscender)
        dataHandle.write(sTypoDescender)
        dataHandle.write(sTypoLineGap)
        dataHandle.write(usWinAscent)
        dataHandle.write(usWinDescent)
        if version >= .version1 {
            dataHandle.write(ulCodePageRange1)
            dataHandle.write(ulCodePageRange2)
            if version >= .version2 {
                dataHandle.write(sxHeight)
                dataHandle.write(sCapHeight)
                dataHandle.write(usDefaultChar)
                dataHandle.write(usBreakChar)
                dataHandle.write(usMaxContext)
                if version >= .version5 {
                    dataHandle.write(usLowerOpticalPointSize)
                    dataHandle.write(usUpperOpticalPointSize)
                }
            }
        }
    }
}

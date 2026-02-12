//
//  OS2Types.swift
//  CoreFont
//
//  Created by Mark Douma on 1/29/2026.
//

import Foundation
import RFSupport

public extension FontTable_OS2 {
    
    enum Weight: Comparable {
        public typealias RawValue = UInt16

        case custom(UInt16)
        case none
        case thin
        case extraLight
        case light
        case normal
        case medium
        case semibold
        case bold
        case extraBold
        case black
        case extraBlack

        public var rawValue: UInt16 {
            switch self {
                case .custom(let v): return v
                case .none:         return 0
                case .thin:         return 100
                case .extraLight:   return 200
                case .light:        return 300
                case .normal:       return 400
                case .medium:       return 500
                case .semibold:     return 600
                case .bold:         return 700
                case .extraBold:    return 800
                case .black:        return 900
                case .extraBlack:   return 950
            }
        }

        public init(rawValue: UInt16) {
            switch rawValue {
                case 0:     self = .none
                case 100:   self = .thin
                case 200:   self = .extraLight
                case 300:   self = .light
                case 400:   self = .normal
                case 500:   self = .medium
                case 600:   self = .semibold
                case 700:   self = .bold
                case 800:   self = .extraBold
                case 900:   self = .black
                case 950:   self = .extraBlack
                default:
                    self = .custom(rawValue)
            }
        }

        public static func == (lhs: Weight, rhs: Weight) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }

        public static func < (lhs: Weight, rhs: Weight) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }

        /// synonyms
        public static let ultraLight    = Self.extraLight
        public static let regular       = Self.normal
        public static let demibold      = Self.medium
        public static let ultraBold     = Self.extraBold
        public static let heavy         = Self.black
        public static let ultra         = Self.black
        public static let nord          = Self.black
        public static let poster        = Self.black
        public static let ultraBlack    = Self.extraBlack
    }

    @objc enum Width: UInt16, Comparable {
        case ultraCondensed     = 1
        case extraCondensed     = 2
        case condensed          = 3
        case semiCondensed      = 4
        case normal             = 5
        case semiExpanded       = 6
        case expanded           = 7
        case extraExpanded      = 8
        case ultraExpanded      = 9
        case unknown            = 0xffff

        public static func == (lhs: Width, rhs: Width) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }

        public static func < (lhs: Width, rhs: Width) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }

    struct FontType: OptionSet {
        public let rawValue: UInt16

        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
        public static let installableEmbedding:  FontType = []
                                                                                    /// bit 0; reserved, set to 0
        public static let restrictedEmbedding:   FontType = .init(rawValue: 1 << 1) /// 0x0002, 2; bit 1; font cannot be
                                                                                    /// embedded (to work, must be only level of embedding selected)
        public static let previewPrintEmbedding: FontType = .init(rawValue: 1 << 2) /// 0x0004, 4; bit 2; font can be installed
                                                                                    /// temp for read-only doc access
        public static let editableEmbedding:     FontType = .init(rawValue: 1 << 3) /// 0x0008, 8; bit 3; font can be installed temp for doc editing
                                                                                    /// bits 4 - 7; reserved, set to 0
        public static let noSubsetting:          FontType = .init(rawValue: 1 << 8) /// 0x0100, 256; bit 8; no subsetting prior to embedding
        public static let bitmapEmbedding:       FontType = .init(rawValue: 1 << 9) /// 0x0200, 512; bit 9; no outline data may be embedded, bitmap data only
    }

    struct Selection: OptionSet {
        public let rawValue: UInt16

        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }

        public static let none:             Selection = []
        public static let italic:           Selection = .init(rawValue: 1 << 0) // 1, font contains italic or oblique chars (sync w/ head.macStyle bit 1)
        public static let underscore:       Selection = .init(rawValue: 1 << 1) // 2, chars are underscoreed
        public static let negative:         Selection = .init(rawValue: 1 << 2) // 4, chars have foreground & background reversed
        public static let outlined:         Selection = .init(rawValue: 1 << 3) // 8, chars are outlined (hollow), otherwise they're solid
        public static let strikeout:        Selection = .init(rawValue: 1 << 4) // 16, chars are overstruck
        public static let bold:             Selection = .init(rawValue: 1 << 5) // 32, chars are bold (sync w/ head.macStyle bit 0)
        public static let regular:          Selection = .init(rawValue: 1 << 6) // 64, chars are stnd. weight/style; if set, .bold, .italic, &/or .oblique must NOT be set
        public static let useTypoMetrics:   Selection = .init(rawValue: 1 << 7) // 128, (ver 4+) if set, use .sTypoAscender - .sTypoDescender + .sTypoLineGap as default line spacing
        public static let wws:              Selection = .init(rawValue: 1 << 8) // 256, (ver 4+) family contains faces that differ only in weight, width, or slope (WWS)
        public static let oblique:          Selection = .init(rawValue: 1 << 9) // 512, (ver 4+) font contains oblique chars
    }

    // FIXME: work on defining/expanding this?
    // FIXME: this is only accurate for Latin Text?:
    final class Panose: FontTableNode {
        @objc dynamic public var bFamilyType:       UInt8 = 0
        @objc dynamic public var bSerifStyle:       UInt8 = 0
        @objc dynamic public var bWeight:           UInt8 = 0
        @objc dynamic public var bProportion:       UInt8 = 0
        @objc dynamic public var bContrast:         UInt8 = 0
        @objc dynamic public var bStrokeVariation:  UInt8 = 0
        @objc dynamic public var bArmStyle:         UInt8 = 0
        @objc dynamic public var bLetterform:       UInt8 = 0
        @objc dynamic public var bMidline:          UInt8 = 0
        @objc dynamic public var bXHeight:          UInt8 = 0

        public override init(_ reader: BinaryDataReader, offset: Int? = nil, table: FontTable) throws {
            try super.init(reader, offset: offset, table: table)
            bFamilyType = try reader.read()
            bSerifStyle = try reader.read()
            bWeight = try reader.read()
            bProportion = try reader.read()
            bContrast = try reader.read()
            bStrokeVariation = try reader.read()
            bArmStyle = try reader.read()
            bLetterform = try reader.read()
            bMidline = try reader.read()
            bXHeight = try reader.read()
        }

        public override func write(to dataHandle: DataHandle) throws {
            dataHandle.write(bFamilyType)
            dataHandle.write(bSerifStyle)
            dataHandle.write(bWeight)
            dataHandle.write(bProportion)
            dataHandle.write(bContrast)
            dataHandle.write(bStrokeVariation)
            dataHandle.write(bArmStyle)
            dataHandle.write(bLetterform)
            dataHandle.write(bMidline)
            dataHandle.write(bXHeight)
        }
    }
}

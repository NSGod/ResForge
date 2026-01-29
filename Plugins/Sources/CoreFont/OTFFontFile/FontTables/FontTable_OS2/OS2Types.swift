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
                case .ultraBold:    return 800
                case .black:        return 900
                case .heavy:        return 900
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

        public static let ultraBold     = Self.black
        public static let heavy         = Self.black
        public static let ultra         = Self.black
        public static let nord          = Self.black
        public static let poster        = Self.black
        public static let ultraBlack    = Self.extraBlack
    }

    enum Width: Comparable {
        case custom(UInt16)
        case ultraCondensed
        case extraCondensed
        case condensed
        case semiCondensed
        case normal
        case semiExpanded
        case expanded
        case extraExpanded
        case ultraExpanded
        case unknown

        public var rawValue: UInt16 {
            switch self {
                case .custom(let v):     return v
                case .ultraCondensed:   return 1
                case .extraCondensed:    return 2
                case .condensed:        return 3
                case .semiCondensed:    return 4
                case .normal:           return 5
                case .semiExpanded:     return 6
                case .expanded:         return 7
                case .extraExpanded:    return 8
                case .ultraExpanded:    return 9
                case .unknown:          return UInt16.max
            }
        }

        public init(rawValue: UInt16) {
            switch rawValue {
                case 1:         self = .ultraCondensed
                case 2:         self = .extraCondensed
                case 3:         self = .condensed
                case 4:         self = .semiCondensed
                case 5:         self = .normal
                case 6:         self = .semiExpanded
                case 7:         self = .expanded
                case 8:         self = .extraExpanded
                case 9:         self = .ultraExpanded
                case UInt16.max:    self = .unknown
                default :       self = .custom(rawValue)
            }
        }

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
        public static let installableEmbedding:     FontType = []
        /// bit 0; reserved, set to 0
        public static let restrictedEmbedding:      FontType = .init(rawValue: 1 << 1) /// 0x0002, 2; bit 1; font cannot be
                                                                                /// embedded (to work, must be only level of embedding selected)
        public static let previewPrintEmbedding:    FontType = .init(rawValue: 1 << 2) /// 0x0004, 4; bit 2; font can be installed
                                                                                /// temp for read-only doc access
        public static let editableEmbedding:        FontType = .init(rawValue: 1 << 3) /// 0x0008, 8; bit 3; font can be installed temp for doc editing
        /// bits 4 - 7; reserved, set to 0
        public static let noSubsetting:             FontType = .init(rawValue: 1 << 8) /// 0x0100, 256; bit 8; no subsetting prior to embedding
        public static let bitmapEmbedding:          FontType = .init(rawValue: 1 << 9) /// 0x0200, 512; bit 9; no outline data may be embedded, bitmap data only
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

    final class Panose: FontTableNode {
        @objc public var panose0: UInt8 = 0
        @objc public var panose1: UInt8 = 0
        @objc public var panose2: UInt8 = 0
        @objc public var panose3: UInt8 = 0
        @objc public var panose4: UInt8 = 0
        @objc public var panose5: UInt8 = 0
        @objc public var panose6: UInt8 = 0
        @objc public var panose7: UInt8 = 0
        @objc public var panose8: UInt8 = 0
        @objc public var panose9: UInt8 = 0

        public override init(_ reader: BinaryDataReader, offset: Int? = nil, table: FontTable) throws {
            try super.init(reader, offset: offset, table: table)
            panose0 = try reader.read()
            panose1 = try reader.read()
            panose2 = try reader.read()
            panose3 = try reader.read()
            panose4 = try reader.read()
            panose5 = try reader.read()
            panose6 = try reader.read()
            panose7 = try reader.read()
            panose8 = try reader.read()
            panose9 = try reader.read()
        }
    }
}

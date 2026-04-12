//
//  Types.swift
//  CoreFont
//
//  Created by Mark Douma on 4/4/2026.
//

import Foundation

extension FontTable_glyf {

    public struct Flags: OptionSet, CustomStringConvertible, CustomDebugStringConvertible, CaseIterable {
        public var rawValue: UInt8

        public static let none:                     Flags = []
        public static let onCurvePoint:             Flags = .init(rawValue: 1 << 0) /// (1,  0x01) if set, point is on the curve, otherwise it's off curve
        public static let shortX:                   Flags = .init(rawValue: 1 << 1) /// (2,  0x02) if set, xCoordinate is an (U)Int8, otherwise it's an (U)Int16
        public static let shortY:                   Flags = .init(rawValue: 1 << 2) /// (4,  0x04) if set, yCoordinate is an (U)Int8, otherwise it's an (U)Int16
        public static let `repeat`:                 Flags = .init(rawValue: 1 << 3) /// (8,  0x08) if set, next byte specifies num (UInt8) times flags
                                                                                    ///     should be repeated
        public static let shortXIsPosOrNextXIsSame: Flags = .init(rawValue: 1 << 4) /// (16, 0x10) if `shortX` is set, then having this bit set means positive,
                                                                                    ///  otherwise negative; if `shortX` isn't set, then if set, this xCoordinate
                                                                                    ///  is the same as previous xCoordinate; if this bit is not set, then current
                                                                                    ///  xCoordinate is signed 16-bit delta vector representing change in x.

        public static let shortYIsPosOrNextYIsSame: Flags = .init(rawValue: 1 << 5) /// (32, 0x20) if `shortY` is set, then having this bit set means pos,
                                                                                    /// otherwise neg; if `shortY` isn't set, then if set, this yCoordinate
                                                                                    /// is the same as previous yCoordinate

        public static let overlapSimple:            Flags = .init(rawValue: 1 << 6) /// (64, 0x40) ? used or deprecated?

        // OURS:
        public static let cubic:                    Flags = .init(rawValue: 1 << 7) /// (128, 0x80) used by fontTools
        public static let undefined:                Flags = .init(rawValue: 255)    /// ours (mine)

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        public var flagDescription: String {
            switch self {
                case .none: return "none"
                case .onCurvePoint: return "onCurvePoint"
                case .shortX: return "shortX"
                case .shortY: return "shortY"
                case .repeat: return "repeat"
                case .shortXIsPosOrNextXIsSame: return "shortXIsPosOrNextXIsSame"
                case .shortYIsPosOrNextYIsSame: return "shortYIsPosOrNextYIsSame"
                case .overlapSimple: return "overlapSimple"
                case .cubic: return "cubic"
                case .undefined:  return "undefined"
                default: return "\(rawValue)"
            }
        }

        public var description: String {
            var desc = "["
            for flag in Flags.allCases {
                if contains(flag) {
                    desc += flag.flagDescription
                    desc += " "
                }
            }
            desc += "]"
            return desc
        }

        public var debugDescription: String { return description }
        
        public static var allCases: [Flags] {
            return [.onCurvePoint, .shortX, .shortY, .repeat, .shortXIsPosOrNextXIsSame, .shortYIsPosOrNextYIsSame, .overlapSimple, .cubic, .undefined]
        }
    }

}

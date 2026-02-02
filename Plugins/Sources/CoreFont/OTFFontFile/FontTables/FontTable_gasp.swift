//
//  FontTable_gasp.swift
//  FontEditor
//
//  Created by Mark Douma on 1/25/2026.
//

import Foundation
import RFSupport

/// - Note: PPEM = Pixels Per Em
///
final public class FontTable_gasp: FontTable {
    @objc public enum Version: UInt16 {
        case version0 = 0
        case version1 = 1
    }

    @objc public var version:       Version = .version0
    @objc public var numRanges:     UInt16 = 0

    @objc public var ranges:        [Range] = []    // sorted by PPEM

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        let vers: UInt16 = try reader.read()
        guard let version = Version(rawValue: vers) else {
            throw FontTableError.unknownVersion("Unknown 'gasp' version: \(vers)")
        }
        self.version = version
        numRanges = try reader.read()
        ranges = try (0..<numRanges).map { _ in try Range(reader, table: self) }
    }
}

public extension FontTable_gasp {

    final class Range: FontTableNode, Comparable {

        public struct Behavior: OptionSet {
            public let rawValue: UInt16
            public init(rawValue: UInt16) {
                self.rawValue = rawValue
            }
            
            public static let none:                 Behavior = []
            public static let gridfit:              Behavior = .init(rawValue: 1 << 0) // Use gridfitting; med. sizes, 9 <= ppem <= 16
            public static let doGray:               Behavior = .init(rawValue: 1 << 1) // Use grayscale rendering; small sizes, ppem < 9
            public static let symmetricGridfit:     Behavior = .init(rawValue: 1 << 2) // ver 1+; Use gridfitting w/ ClearType smoothing
            public static let symmetricSmoothing:   Behavior = .init(rawValue: 1 << 3) // ver 1+; Use ClearType smoothing

            public static let version0Mask : Behavior = [.gridfit, .doGray]
            public static let version1Mask : Behavior = [.gridfit, .doGray, .symmetricGridfit, .symmetricSmoothing]
        }

        @objc public var maxPPEM:       UInt16 = 0
        public var behavior:            Behavior = .none

        @objc public var objcBehavior:  UInt16 = 0 {
            didSet {
                behavior = .init(rawValue: objcBehavior)
            }
        }

        public static let nodeLength: Int = MemoryLayout<UInt16>.size * 2 // 4

        public override init(_ reader: BinaryDataReader, offset: Int? = nil, table: FontTable) throws {
            try super.init(reader, offset: offset, table: table)
            maxPPEM = try reader.read()
            behavior = Behavior(rawValue: try reader.read())
            objcBehavior = behavior.rawValue
        }

        public static func < (lhs: FontTable_gasp.Range, rhs: FontTable_gasp.Range) -> Bool {
            return lhs.maxPPEM < rhs.maxPPEM
        }

        public static func == (lhs: FontTable_gasp.Range, rhs: FontTable_gasp.Range) -> Bool {
            return lhs.maxPPEM == rhs.maxPPEM &&
            lhs.behavior == rhs.behavior
        }
    }
}

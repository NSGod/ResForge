//
//  FontTable_bloc.swift
//  CoreFont
//
//  Created by Mark Douma on 3/21/2026.
//

/// Some of the descriptions are taken, in part, from Adobe's afdko code at:
/// https://github.com/adobe-type-tools/afdko/blob/develop/c/spot/sfnt_includes/sfnt_bloc.h
/// https://github.com/adobe-type-tools/afdko/blob/develop/c/spot/sfnt_includes/sfnt_sbit.h
/* Copyright 2014 Adobe Systems Incorporated (http://www.adobe.com/). All Rights Reserved.
   This software is licensed as OpenSource, under the Apache License, Version 2.0.
   This license is available at: http://opensource.org/licenses/Apache-2.0. */

import Foundation
import RFSupport

public class FontTable_bloc: FontTable {

    @objc public enum Version: Fixed {
        case default2_0 = 0x00020000

        public init?(rawValue: Fixed) {
            switch rawValue {
                case 0x00020000: self = .default2_0
                default:
                    NSLog("\(type(of: self)).\(#function) *** WARNING: unknown version: \(String(format: "0x%08X", rawValue)); using .default2_0")
                    self = .default2_0
            }
        }
    }

    // MARK: -
    @objc public var version:           Version = .default2_0
    @objc public var numSizes:          UInt32 = 0
    public var sizes:                   [BitmapSizeTable] = []  // [numSizes]
    private var indexSubTables:         [IndexSubtableArray] = []

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        version = try reader.read()
        numSizes = try reader.read()
        for _ in 0..<numSizes {
            let size = try BitmapSizeTable(reader)
            sizes.append(size)
        }
        for size in sizes {
            let indexSubtableArray = try IndexSubtableArray(reader, offset: Int(size.indexSubTableArrayOffset))
            indexSubTables.append(indexSubtableArray)
        }
    }
}

extension FontTable_bloc {

    public class BitmapSizeTable: Node {

        public struct Flags: OptionSet {
            public let rawValue: UInt8

            public init(rawValue: UInt8) {
                self.rawValue = rawValue
            }

            public static let horizontal:   Flags = Flags(rawValue: 1 << 0) // small metrics are hor
            public static let vertical:     Flags = Flags(rawValue: 1 << 1) // small metrics are vert
        }

        // MARK: -
        public var indexSubTableArrayOffset:    UInt32 = 0          /// Offset to corresponding index subtable array from the beginning of the `bloc`.
        public var indexTableSize:              UInt32 = 0          /// Length of corresponding index subtables and array
        public var numberOfIndexSubTables:      UInt32 = 0          /// Number of index subtables (there is one for each range or format change).
        public var colorRef:                    UInt32 = 0          /// not used by Apple
        public var hori:                        Sbit.LineMetrics!   /// horizontal line metrics
        public var vert:                        Sbit.LineMetrics!   /// vertical line metrics
        public var startGlyphIndex:             GlyphID = 0         /// lowest glyph index for this size
        public var endGlyphIndex:               GlyphID = 0         /// highest glyph index for this size
        public var ppemX:                       UInt8 = 0           /// target horizontal pixels-per-em
        public var ppemY:                       UInt8 = 0           /// target vertical pixels-per-em
        public var bitDepth:                    UInt8 = 0           /// bit depth of the strike
        public var flags:                       Flags = []

        public override class var nodeLength: UInt32 {
            return UInt32(16 + Sbit.LineMetrics.nodeLength * 2 + 4 + 4)  // 48
        }

        public required init(_ reader: BinaryDataReader? = nil, offset: Int? = nil) throws {
            try super.init(reader, offset: offset)
            if let reader {
                indexSubTableArrayOffset = try reader.read()
                indexTableSize = try reader.read()
                numberOfIndexSubTables = try reader.read()
                colorRef = try reader.read()
                hori = try Sbit.LineMetrics(reader)
                vert = try Sbit.LineMetrics(reader)
                startGlyphIndex = try reader.read()
                endGlyphIndex = try reader.read()
                ppemX = try reader.read()
                ppemY = try reader.read()
                bitDepth = try reader.read()
                flags = Flags(rawValue: try reader.read())
            }
        }
    }

}

/// Microsoft equivalent to Apple's `bloc` table
/// Different name but identical function
public final class FontTable_EBLC: FontTable_bloc {

}

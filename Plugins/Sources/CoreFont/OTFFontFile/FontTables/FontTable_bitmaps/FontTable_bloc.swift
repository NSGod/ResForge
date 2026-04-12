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

/// `REQUIRES`: `maxp`
/// `DEPENDS ON`:
/// `DISPLAY DEPENDS ON`:
///
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
    public var numSizes:                UInt32 = 0
    public var sizes:                   [Sbit.BitmapSizeTable] = []      // [numSizes]

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        version = try reader.read()
        numSizes = try reader.read()
        sizes = try (0..<numSizes).map { _ in try Sbit.BitmapSizeTable(reader) }
    }
}

/// Microsoft equivalent to Apple's `bloc` table
/// Different name but identical function
public final class FontTable_EBLC: FontTable_bloc {

}

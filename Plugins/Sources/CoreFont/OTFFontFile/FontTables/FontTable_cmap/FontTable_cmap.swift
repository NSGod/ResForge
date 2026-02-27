//
//  FontTable_cmap.swift
//  CoreFont
//
//  Created by Mark Douma on 2/23/2026.
//

import Foundation
import RFSupport

/// `REQUIRES`:
/// `DEPENDS ON`:
/// `DISPLAY DEPENDS ON`: 'post'

/* "The encoding record entries in the 'cmap' header must be sorted first by platform ID, then
 by platform-specific encoding ID, and then by the language field in the corresponding subtable.
 Each platform ID, platform-specific encoding ID, and subtable language combination may appear
 only once in the 'cmap' table." */

public final class FontTable_cmap: FontTable {
    @objc public enum Version: UInt16 {
        case default0 = 0
    }

    @objc dynamic public var version:           Version = .default0
    @objc dynamic public var nEncodings:        UInt16 = 0

    @objc dynamic public var encodings:         [Encoding] = []

    // MARK: AUX
    @objc dynamic public var preferredEncoding: Encoding!

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        let vers: UInt16 = try reader.read()
        guard let versn = Version(rawValue: vers) else {
            throw FontTableError.unknownVersion("Unknown 'cmap' version: \(vers)")
        }
        self.version = versn
        nEncodings = try reader.read()
        encodings = try (0..<nEncodings).map { _ in try Encoding(reader, table: self) }
    }

    public func glyphID<T>(forCharCode: T) -> T? where T: BinaryInteger {

        return 0
    }

    public func glyphID(for charCode: CharCode32) -> Glyph32ID {

        return 0
    }

    public func encodingsFor(platformID: PlatformID, encodingID: EncodingID) -> [Encoding]? {

        return nil
    }

}


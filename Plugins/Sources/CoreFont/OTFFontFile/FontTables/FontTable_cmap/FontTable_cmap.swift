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
/// `DISPLAY DEPENDS ON`: `post`

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

    override func prepareToWrite() throws {
        version = .default0
        nEncodings = UInt16(encodings.count)
        encodings.sort(by: <)
        var offset: UInt32 = UInt32(MemoryLayout<UInt16>.size) * 2 + UInt32(nEncodings) * Encoding.nodeLength
        encodings.forEach {
            $0.offset = offset
            offset += $0.subtable.nodeLength
        }
    }

    override func write() throws {
        dataHandle.write(version)
        dataHandle.write(nEncodings)
        try encodings.forEach { try $0.write(to: dataHandle) }
    }

    public func glyphID<T>(forCharCode: T) -> T? where T: BinaryInteger {

        return 0
    }

    public func glyphID(for charCode: CharCode32) -> GlyphID32 {
        return preferredEncoding.glyphID(for: charCode)
    }

    /// O(n)
    public func encodingsFor(platformID: PlatformID, encodingID: EncodingID = .any, languageID: LanguageID = .any) -> [Encoding]? {
        let encodings = encodings.filter {
            $0.platformID == platformID &&
            ($0.encodingID == encodingID || encodingID == .any) &&
            ($0.subtable.languageID.rawValue == languageID.rawValue || languageID == .any)
        }
        return encodings
    }
}


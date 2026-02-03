//
//  NameRecord.swift
//  CoreFont
//
//  Created by Mark Douma on 1/23/2026.
//

import Foundation
import RFSupport

public extension FontTable_name {

    final class NameRecord: FontTableNode, Comparable {
        public var platformID:      PlatformID = .any   // base-0
        public var encodingID:      EncodingID = .none  // aka `platformSpecificID`/`scriptID`; base-0
        public var languageID:      LanguageID = .none  // base-0

        public var nameID:          FontNameID  = .any  // base-0
        public var length:          UInt16 = 0          // name string length in bytes
        public var offset:          UInt16 = 0          // name string offset in bytes from stringOffset

        @objc public var string:    String = ""
        public var data:            Data!

        public override var nodeLength: UInt32 {
            return UInt32(MemoryLayout<UInt16>.size * 6) // 12
        }

        public class override var nodeLength: UInt32 {
            return UInt32(MemoryLayout<UInt16>.size * 6) // 12
        }

        // MARK: AUX: for display:
        @objc var platformName:     String = ""
        @objc var scriptName:       String = ""
        @objc var languageName:     String = ""
        @objc var name:             String = ""
        @objc var value:            String = ""

        public init(_ reader: BinaryDataReader, stringOffset: UInt16, table: FontTable) throws {
            try super.init(reader, table: table)
            guard let platID = PlatformID(rawValue: try reader.read()) else {
                throw FontTableError.parseError("Unexpected PlatformID")
            }
            platformID = platID
            encodingID = try EncodingID.encodingIDWith(platformID: platformID, encodingID: try reader.read())
            languageID = try LanguageID.languageIDWith(platformID: platformID, languageID: try reader.read())
            nameID = FontNameID(rawValue: try reader.read())
            length = try reader.read()
            offset = try reader.read()
            try reader.pushPosition(Int(stringOffset + offset))
            data = try reader.readData(length: Int(length))
            reader.popPosition()
            if platformID == .unicode {
                string = String(data: data, encoding: .utf16BigEndian) ?? ""
            } else if platformID == .mac {
                var stringEncoding: String.Encoding = .utf8
                let encoding = CFStringConvertEncodingToNSStringEncoding(UInt32(encodingID.rawValue))
                if encoding == kCFStringEncodingInvalidId {
                    NSLog("\(type(of: self)).\(#function) *** ERROR/WARNING: could not find NSStringEncoding for scriptID: \(encodingID.rawValue)")
                } else {
                    stringEncoding = String.Encoding(rawValue: encoding)
                }
                string = String(data: data, encoding: stringEncoding) ?? ""
            } else if platformID == .microsoft {
                string = String(data: data, encoding: .utf16BigEndian) ?? ""
            }
            platformName = NSLocalizedString("[\(platformID.rawValue)] \(platformID)", comment: "")
            scriptName = NSLocalizedString("[\(encodingID.rawValue)] \(encodingID)", comment: "")
            languageName = NSLocalizedString("[\(languageID.rawValue)] \(languageID)", comment: "")
            if nameID.rawValue <= FontNameID.varsPostScriptNamePrefix.rawValue {
                name = NSLocalizedString("[\(nameID.rawValue)] \(nameID)", comment: "")
            } else {
                name = "\(nameID)"
            }
            value = string
        }

        @available(*, unavailable, message: "use initializer that takes stringOffset instead")
        public override init(_ reader: BinaryDataReader, offset: Int? = nil, table: FontTable) throws {
            fatalError("")
        }

        /// "As with encoding records in the 'cmap' table, name records shall be sorted first by platform ID,
        /// then by encoding ID, then language ID, and then, in addition, by name ID.
        public static func < (lhs: FontTable_name.NameRecord, rhs: FontTable_name.NameRecord) -> Bool {
            if lhs.platformID != rhs.platformID { return lhs.platformID < rhs.platformID }
            if lhs.encodingID != rhs.encodingID { return lhs.encodingID < rhs.encodingID }
            if lhs.languageID != rhs.languageID { return lhs.languageID < rhs.languageID }
            return lhs.nameID < rhs.nameID
        }

        public static func == (lhs: FontTable_name.NameRecord, rhs: FontTable_name.NameRecord) -> Bool {
            return lhs.platformID == rhs.platformID &&
            lhs.nameID     == rhs.nameID &&
            lhs.length     == rhs.length &&
            lhs.offset    == rhs.offset &&
            lhs.platformID == rhs.platformID &&
            lhs.encodingID == rhs.encodingID &&
            lhs.languageID == rhs.languageID
        }
    }
}

//
//  LanguageTagRecord.swift
//  CoreFont
//
//  Created by Mark Douma on 1/24/2026.
//

import Foundation
import RFSupport

public extension FontTable_name {
    /// not really used much; unsupported by Apple
    final class LanguageTagRecord: FontTableNode {
        @objc public var length:        UInt16 = 0  // string length in bytes
        @objc public var offset:        UInt16 = 0  // string offset from start of storage area
        @objc public var string:        String = ""

        public init(_ reader: BinaryDataReader,  stringOffset: UInt16, table: FontTable) throws {
            try super.init(reader, table: table)
            length = try reader.read()
            self.offset = try reader.read()
            try reader.pushPosition(Int(stringOffset + offset))
            let data = try reader.readData(length: Int(length))
            reader.popPosition()
            string = String(data: data, encoding: .utf16BigEndian) ?? ""
        }

        @available(*, unavailable, message: "use initializer that takes stringOffset instead")
        public override init(_ reader: BinaryDataReader, offset: Int? = nil, table: FontTable) throws {
            fatalError("use initializer that takes stringOffset instead")
        }
    }
}

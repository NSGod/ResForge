//
//  SettingName.swift
//  CoreFont
//
//  Created by Mark Douma on 2/27/2026.
//

import Foundation
import RFSupport

public typealias Setting = UInt16

extension FontTable_feat {

    /// https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6feat.html
    /// https://developer.apple.com/fonts/TrueType-Reference-Manual/RM09/AppendixF.html
    
    public final class SettingName: FontTableNode {
        @objc public var setting:   Setting = 0
        public var nameID:          FontTable_name.FontNameID = .any // 255 < nameID < 32768

        // MARK: AUX:
        @objc dynamic lazy public var name:      String = {
            return table.nameTable?.nameFor(nameID: self.nameID) ?? "<unknown>"
        }()

        public override class var nodeLength: UInt32 { 4 }

        public override init(_ reader: BinaryDataReader?, offset: Int? = nil, table: FontTable) throws {
            try super.init(reader, offset: offset, table: table)
            guard let reader, let offset else { throw FontTableError.parseError("No reader or offset") }
            reader.pushSavedPosition()
            try reader.setPosition(offset)
            setting = try reader.read()
            nameID = FontTable_name.FontNameID(rawValue: try reader.read())
            reader.popPosition()
        }

        public override func write(to handle: DataHandle, offset: Int? = nil) throws {
            assert(offset != nil)
            guard let offset else { throw FontTableError.writeError("No offset") }
            handle.pushSavedOffset()
            handle.seek(to: offset)
            handle.write(setting)
            handle.write(nameID.rawValue)
            handle.popAndSeekToSavedOffset()
        }
    }
}

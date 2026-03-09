//
//  FeatureName.swift
//  CoreFont
//
//  Created by Mark Douma on 2/27/2026.
//

import Foundation
import RFSupport

extension FontTable_feat {

    @objc public enum Flag: UInt16 {
        case none       = 0
        case exclusive  = 0x8000 /// if set, feature settings are mutually exclusive
    }

    /// https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6feat.html
    /// https://developer.apple.com/fonts/TrueType-Reference-Manual/RM09/AppendixF.html

    public final class FeatureName: FontTableNode {
        @objc public var feature:           FeatureType = .none
        @objc public var nSettings:         UInt16 = 0
        @objc public var settingOffset:     UInt32 = 0
        @objc public var flags:             Flag = .none
        public var nameID:                  FontTable_name.FontNameID = .any    // 255 < nameID < 32768

        @objc dynamic public var settings:  [SettingName] = []

        // MARK: AUX:
        @objc dynamic lazy public var name: String = {
            return table.nameTable?.nameFor(nameID: nameID) ?? "<unknown>"
        }()

        public override class var nodeLength: UInt32 { UInt32(MemoryLayout<UInt16>.size) * 4 + UInt32(MemoryLayout<UInt32>.size) } // 12

        public override init(_ reader: BinaryDataReader?, offset: Int? = nil, table: FontTable) throws {
            assert(offset == nil)
            try super.init(reader, offset: offset, table: table)
            if let reader {
                feature = try reader.read()
                nSettings = try reader.read()
                settingOffset = try reader.read()
                flags = try reader.read()
                nameID = FontTable_name.FontNameID(rawValue: try reader.read())
                for i in 0..<UInt32(nSettings) {
                    let setting = try SettingName(reader, offset: Int(settingOffset + SettingName.nodeLength * i), table: table)
                    settings.append(setting)
                }
            }
        }

        public override func write(to handle: DataHandle, offset: Int? = nil) throws {
            assert(offset == nil)
            nSettings = UInt16(settings.count)
            handle.write(feature)
            handle.write(nSettings)
            handle.write(settingOffset)
            handle.write(flags)
            try settings.forEach { try $0.write(to: handle, offset: Int(settingOffset)) }
        }
    }
}

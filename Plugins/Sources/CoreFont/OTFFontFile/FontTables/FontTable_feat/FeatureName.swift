//
//  FeatureName.swift
//  CoreFont
//
//  Created by Mark Douma on 2/27/2026.
//

import Foundation
import RFSupport

extension FontTable_feat {

    @objc public enum Flags: UInt16 {
        case none       = 0
        case exclusive  = 0x8000 /// if set, feature settings are mutually exclusive
    }

    /// https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6feat.html
    /// https://developer.apple.com/fonts/TrueType-Reference-Manual/RM09/AppendixF.html

    public final class FeatureName: FontTableNode {
        public var feature:             FeatureType = .none
        public var nSettings:           UInt16 = 0
        public var settingOffset:       UInt32 = 0
        public var flags:               Flags = .none
        public var nameID:              FontTable_name.FontNameID = .any    // 255 < nameID < 32768

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
                let feat: UInt16 = try reader.read()
                if let featureType = FeatureType(rawValue: feat) {
                    feature = featureType
                } else {
                    NSLog("\(type(of: self)).\(#function) *** ERROR: unknown feature: \(feat)")
                }
                nSettings = try reader.read()
                settingOffset = try reader.read()
                flags = try reader.read()
                nameID = FontTable_name.FontNameID(rawValue: try reader.read())
                reader.pushSavedPosition()
                defer { reader.popPosition() }
                try reader.setPosition(settingOffset)
                settings = try (0..<nSettings).map { _ in try SettingName(reader, table: table) }
            }
        }

        public override func write(to handle: DataHandle, offset: Int? = nil) throws {
            assert(offset == nil)
            nSettings = UInt16(settings.count)
            handle.write(feature)
            handle.write(nSettings)
            handle.write(settingOffset)
            handle.write(flags)
            handle.write(nameID)
            handle.pushSavedOffset()
            defer { handle.popAndSeekToSavedOffset() }
            handle.seek(to: settingOffset)
            try settings.forEach { try $0.write(to: handle) }
        }
    }
}

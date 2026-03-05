//
//  Encoding.swift
//  CoreFont
//
//  Created by Mark Douma on 2/24/2026.
//

import Foundation
import RFSupport

extension FontTable_cmap {

    public final class Encoding: FontTableNode, Comparable {
        public var platformID:      PlatformID  = .any  /// base-0
        public var encodingID:      EncodingID  = .any  /// base-0; aka `platformSpecificID/scriptID`
        public var offset:          UInt32 = 0          /// byte offset from beginning of table to subtable

        @objc dynamic public var subtable:  Subtable!

        public override class var nodeLength: UInt32 {
            return UInt32(MemoryLayout<UInt16>.size * 2 + MemoryLayout<UInt32>.size) // 8
        }

        // MARK: for display:
        @objc dynamic public lazy var platformScriptName:   String = {
            loadDisplayNamesIfNeeded()
            return _platformScriptName
        }()

        @objc dynamic public lazy var platformName:         String = {
            loadDisplayNamesIfNeeded()
            return _platformName
        }()

        @objc dynamic public lazy var scriptName:           String = {
            loadDisplayNamesIfNeeded()
            return _scriptName
        }()

        @objc dynamic public lazy var languageName:         String? = {
            loadDisplayNamesIfNeeded()
            return _languageName
        }()

        @objc dynamic private var _platformScriptName:  String = ""
        @objc dynamic private var _platformName:        String = ""
        @objc dynamic private var _scriptName:          String = ""
        @objc dynamic private var _languageName:        String?
        private var _displayNamesLoaded = false

        public override init(_ reader: BinaryDataReader?, offset: Int? = nil, table: FontTable) throws {
            guard let reader else { throw FontTableError.parseError("No reader") }
            try super.init(reader, offset: offset, table: table)
            guard let platID = PlatformID(rawValue: try reader.read()) else {
                throw FontTableError.parseError("Unexpected PlatformID")
            }
            platformID = platID
            encodingID = try EncodingID.encodingIDWith(platformID: platformID, encodingID: try reader.read())
            self.offset = try reader.read()
            try reader.pushPosition(Int(self.offset))
            guard let fmt = Subtable.Format(rawValue: try reader.peek()) else {
                throw FontTableError.parseError("Unexpected 'cmap' Encoding Subtable Format")
            }
            guard let subtableClass: Subtable.Type = Subtable.class(for: fmt) else {
                throw FontTableError.parseError("Unsupported 'cmap' Encoding Subtable format: \(fmt)")
            }
            subtable = try subtableClass.init(reader, encoding: self, table: table)
            reader.popPosition()
        }

        private func loadDisplayNamesIfNeeded() {
            if _displayNamesLoaded { return }
            _platformName = NSLocalizedString("[\(platformID.rawValue)] \(platformID.description)", comment: "")
            if platformID == .unicode {
                _scriptName = NSLocalizedString("[\(encodingID.rawValue)] \(encodingID.description)", comment: "")
                _languageName = NSLocalizedString("--", comment: "")
            } else if platformID == .mac {
                _scriptName = NSLocalizedString("[\(encodingID.rawValue)] \(encodingID.description)", comment: "")
                /// if languageID == 0, that means it's not language-dependent
                /// otherwise, subtract 1 from the value to get the real languageID
                let languageID = subtable.languageID.macStandardized()
                if languageID.rawValue == 0 {
                    _languageName = NSLocalizedString("--", comment: "")
                } else {
                    _languageName = NSLocalizedString("[\(languageID.rawValue)] \(languageID.description)", comment: "")
                }
            } else if platformID == .microsoft {
                _scriptName = NSLocalizedString("[\(encodingID.rawValue)] \(encodingID.description)", comment: "")
                // FIXME: is this right:?
                _languageName = NSLocalizedString("--", comment: "")
            }
            _platformScriptName = _platformName + " \(_scriptName)"
            _displayNamesLoaded = true
        }

        public func glyphID(for charCode: CharCode32) -> GlyphID32 {
            return subtable.glyphID(for: charCode)
        }

         /// "The encoding record entries in the 'cmap' header must be sorted first by platform ID, then
         /// by platform-specific encoding ID, and then by the language field in the corresponding subtable.
         /// Each platform ID, platform-specific encoding ID, and subtable language combination may appear
         /// only once in the 'cmap' table."
        public static func < (lhs: Encoding, rhs: Encoding) -> Bool {
            if lhs.platformID != rhs.platformID { return lhs.platformID.rawValue < rhs.platformID.rawValue }
            if lhs.encodingID != rhs.encodingID { return lhs.encodingID.rawValue < rhs.encodingID.rawValue }
            return lhs.subtable.languageID.rawValue < rhs.subtable.languageID.rawValue
        }

        public static func compareForPreferred(lhs: Encoding, rhs: Encoding) -> Bool {

            return false
        }
    }
}

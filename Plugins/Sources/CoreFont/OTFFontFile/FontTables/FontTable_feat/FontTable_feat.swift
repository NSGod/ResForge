//
//  FontTable_feat.swift
//  CoreFont
//
//  Created by Mark Douma on 2/27/2026.
//

import Foundation
import RFSupport

/// `REQUIRES`:
/// `DEPENDS ON`:
/// `DISPLAY DEPENDS ON`: `name`

/// https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6feat.html
/// https://developer.apple.com/fonts/TrueType-Reference-Manual/RM09/AppendixF.html

public final class FontTable_feat: FontTable {
    @objc public enum Version: Fixed {
        case default1_0 = 0x00010000
    }

    @objc dynamic public var version:       Version = .default1_0
    @objc dynamic public var numNames:      UInt16 = 0
    @objc dynamic public var numSets:       UInt16 = 0 /// unused; must be zero
    @objc dynamic public var setOffset:     UInt32 = 0 /// unused; must be zero

    @objc dynamic public var featureNames:  [FeatureName] = []

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        version = try reader.read()
        numNames = try reader.read()
        numSets = try reader.read()
        setOffset = try reader.read()
        featureNames = try (0..<numNames).map { _ in try FeatureName(reader, table: self) }
    }

    override func prepareToWrite() throws {
        numNames = UInt16(featureNames.count)
        numSets = 0
        setOffset = 0
        var offset: UInt32 = 8 + 4 + UInt32(numNames) * FeatureName.nodeLength
        featureNames.forEach {
            $0.settingOffset = offset
            offset += UInt32($0.settings.count) * SettingName.nodeLength
        }
    }

    override func write() throws {
        dataHandle.write(version)
        dataHandle.write(numNames)
        dataHandle.write(numSets)
        dataHandle.write(setOffset)
        try featureNames.forEach { try $0.write(to: dataHandle) }
    }
}

// See the following:
//import CoreText.SFNTLayoutTypes
/// https://developer.apple.com/fonts/TrueType-Reference-Manual/RM09/AppendixF.html

extension FontTable_feat {

    @objc public enum FeatureType: UInt16 {
        case all                        = 0
        case ligatures                  = 1
        case cursiveConnection          = 2
        case letterCase                 = 3 /// deprecated; use `.lowerCase` or `.upperCase`
        case verticalSubstitution       = 4
        case linguisticRearrangement    = 5
        case numberSpacing              = 6
        case smartSwash                 = 8
        case diacritics                 = 9
        case verticalPosition           = 10
        case fractions                  = 11
        case overlappingCharacters      = 13
        case typographicExtras          = 14
        case mathematicalExtras         = 15
        case ornamentSets               = 16
        case characterAlternatives      = 17
        case designComplexity           = 18
        case styleOptions               = 19
        case characterShape             = 20
        case numberCase                 = 21
        case textSpacing                = 22
        case transliteration            = 23
        case annotation                 = 24
        case kanaSpacing                = 25
        case ideographicSpacing         = 26
        case unicodeDecomposition       = 27
        case rubyKana                   = 28
        case cjkSymbolAlternatives      = 29
        case ideographicAlternatives    = 30
        case cjkVerticalRomanPlacement  = 31
        case italicCJKRoman             = 32
        case caseSensitiveLayout        = 33
        case alternateKana              = 34
        case stylisticAlternatives      = 35
        case contextualAlternatives     = 36
        case lowerCase                  = 37
        case upperCase                  = 38
        case languageTag                = 39
        case cjkRomanSpacing            = 103
        case unknown16000               = 16000
        case unknown16001               = 16001
        case none                       = 0xffff

        public init?(rawValue: UInt16) {
            switch rawValue {
                case 0: self = .all
                case 1: self = .ligatures
                case 2: self = .cursiveConnection
                case 3: self = .letterCase
                case 4: self = .verticalSubstitution
                case 5: self = .linguisticRearrangement
                case 6: self = .numberSpacing
                case 8: self = .smartSwash
                case 9: self = .diacritics
                case 10: self = .verticalPosition
                case 11: self = .fractions
                case 13: self = .overlappingCharacters
                case 14: self = .typographicExtras
                case 15: self = .mathematicalExtras
                case 16: self = .ornamentSets
                case 17: self = .characterAlternatives
                case 18: self = .designComplexity
                case 19: self = .styleOptions
                case 20: self = .characterShape
                case 21: self = .numberCase
                case 22: self = .textSpacing
                case 23: self = .transliteration
                case 24: self = .annotation
                case 25: self = .kanaSpacing
                case 26: self = .ideographicSpacing
                case 27: self = .unicodeDecomposition
                case 28: self = .rubyKana
                case 29: self = .cjkSymbolAlternatives
                case 30: self = .ideographicAlternatives
                case 31: self = .cjkVerticalRomanPlacement
                case 32: self = .italicCJKRoman
                case 33: self = .caseSensitiveLayout
                case 34: self = .alternateKana
                case 35: self = .stylisticAlternatives
                case 36: self = .contextualAlternatives
                case 37: self = .lowerCase
                case 38: self = .upperCase
                case 39: self = .languageTag
                case 103: self = .cjkRomanSpacing
                case 16000: self = .unknown16000
                case 16001: self = .unknown16001
                case 0xffff: self = .none
                default:
                    NSLog("\(type(of: self)).\(#function) *** ERROR: unknown rawValue: \(rawValue)")
                    return nil
            }

        }
    }
}

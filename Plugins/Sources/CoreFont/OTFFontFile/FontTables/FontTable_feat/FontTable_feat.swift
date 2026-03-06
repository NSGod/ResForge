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
        case versionDefault1_0 = 0x00010000
    }

    @objc dynamic public var version:       Version = .versionDefault1_0
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
        case none                       = 0xffff
    }
}

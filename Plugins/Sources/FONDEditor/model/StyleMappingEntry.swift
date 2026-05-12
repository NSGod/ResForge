//
//  StyleMappingEntry.swift
//  FONDEditor
//
//  Created by Mark Douma on 4/25/2026.
//

import Cocoa
import CoreFont
import RFSupport

// for display
public final class StyleMappingEntry: NSObject {
    @objc dynamic public var styleIndex:            Int = 0
    public var style:                               MacFontStyle = .regular
    @objc dynamic public var stringIndex:           Int = 0
    @objc dynamic public var fontNameSuffixEntry:   FontNameSuffixEntry

    @objc dynamic public var objcStyle: UInt16 {
        get { style.rawValue }
        set { style = MacFontStyle(rawValue: newValue) }
    }

    public init(abridgedStyle: MacFontStyle, stringIndex: Int, fontNameSuffixEntry: FontNameSuffixEntry) {
        styleIndex = Int(abridgedStyle.rawValue)
        style = abridgedStyle.unabridged()
        self.stringIndex = stringIndex + 1
        self.fontNameSuffixEntry = fontNameSuffixEntry
    }

    public static func entries(from styleMappingTable: FOND.StyleMappingTable, fontNameSuffixEntries: [FontNameSuffixEntry]) -> [StyleMappingEntry] {
        var entries = [StyleMappingEntry]()
        for i in 0..<styleMappingTable.indexes.count {
            var stringIndex = Int(styleMappingTable.indexes[i])
            if stringIndex > 0 { stringIndex -= 1 }
            let fontNameSuffixEntry = fontNameSuffixEntries[Int(stringIndex)]
            let entry = StyleMappingEntry(abridgedStyle: MacFontStyle(rawValue: UInt16(i), isAbridged: true), stringIndex: stringIndex, fontNameSuffixEntry: fontNameSuffixEntry)
            entries.append(entry)
        }
        return entries
    }
}

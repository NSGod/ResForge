//
//  FontNameSuffixEntry.swift
//  FONDEditor
//
//  Created by Mark Douma on 3/8/2026.
//

import Cocoa
import CoreFont
import RFSupport

public final class FontNameSuffixEntry: NSObject, Comparable {
    @objc public enum FontType: Int {
        case sfnt
        case postScript
        case missingPostScript
        case none
    }

    private static var pascalLengthString: NSAttributedString {
        let psString = "\\p"
        let attrs: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
                                                    .foregroundColor: NSColor.tertiaryLabelColor]
        return NSAttributedString(string: psString, attributes: attrs)
    }
    private static var attrs: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
                                                               .foregroundColor: NSColor.labelColor]

    @objc dynamic public var index:                             Int = 0
    @objc dynamic public var encodedAttrStringRepresentation:   NSAttributedString!
    @objc dynamic public var postScriptName:                    String = ""
    @objc dynamic public var lwfnFilename:                      String = ""
    @objc dynamic public var lwfnURL:                           URL?
    public var sfntResID:                                       ResID?
    @objc dynamic public var fontType:                          FontType {
        if sfntResID != nil {
            return .sfnt
        } else if let lwfnURL {
            return FileManager.default.fileExists(atPath: lwfnURL.path) ? .postScript : .missingPostScript
        } else {
            return .none
        }
    }

    public static func entries(from suffixSubtable: FOND.FontNameSuffixSubtable, manager: RFEditorManager) -> [FontNameSuffixEntry] {
        var postScriptNamesToSfntResIDs: [String: Int] = [:]
        /// first look for an 'sfnt' with this PostScript name
        let sfntResources = manager.allResources(ofType: .sfnt, currentDocumentOnly: true)
        do {
            try sfntResources.forEach { resource in
                let fontFile = try OTFFontFile(resource.data)
                postScriptNamesToSfntResIDs[fontFile.postScriptName] = resource.id
            }
        } catch {
            NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
        }
        let docDirURL: URL? = manager.document?.fileURL?.deletingLastPathComponent()
        var entries: [FontNameSuffixEntry] = []
        let entryIndexCount = suffixSubtable.entryIndexesToPostScriptNames.count
        let orderedKeys: [UInt8] = suffixSubtable.entryIndexesToPostScriptNames.keys.sorted()
        for i in 0..<entryIndexCount {
            let entry = FontNameSuffixEntry()
            let key = orderedKeys[i]
            entry.index = Int(key)
            entry.postScriptName = suffixSubtable.entryIndexesToPostScriptNames[key]!
            if key == 1 {
                let mString = Self.pascalLengthString.mutableCopy() as! NSMutableAttributedString
                mString.append(NSAttributedString(string: "\(suffixSubtable.entryIndexesToPostScriptNames[key]!)", attributes: Self.attrs))
                entry.encodedAttrStringRepresentation = mString
            } else {
                let mString = Self.pascalLengthString.mutableCopy() as! NSMutableAttributedString
                mString.append(NSAttributedString(string: suffixSubtable.stringDatas[Int(key - 2)].dropFirst().map { String(format: "%d", $0) }.joined(separator: " "), attributes: Self.attrs))
                entry.encodedAttrStringRepresentation = mString
            }
            if let sfntResID = postScriptNamesToSfntResIDs[entry.postScriptName] {
                entry.sfntResID = ResID(sfntResID)
            } else {
                /// Try to locate the 'LWFN' font file in the same directory as the font suitcase
                let fontFileName = MD533Filename(forPostScriptFontName: entry.postScriptName)
                entry.lwfnFilename = fontFileName
                entry.lwfnURL = docDirURL?.appendingPathComponent(fontFileName)
            }
            entries.append(entry)
        }
        if suffixSubtable.stringCount >= 2 {
            var lastKey: UInt8 = orderedKeys.last! + 1
            for data in suffixSubtable.stringDatas[Int(lastKey - 2)...Int(suffixSubtable.stringCount - 2)] {
                let entry = FontNameSuffixEntry()
                entry.index = Int(lastKey)
                do {
                    let mString = Self.pascalLengthString.mutableCopy() as! NSMutableAttributedString
                    mString.append(NSAttributedString(string: try FOND.FontNameSuffixSubtable.stringFromPString(with: data), attributes: Self.attrs))
                    entry.encodedAttrStringRepresentation = mString
                    try entry.postScriptName = FOND.FontNameSuffixSubtable.stringFromPString(with: data)
                } catch {
                    NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
                }
                entries.append(entry)
                lastKey &+= 1
            }
        }
        return entries
    }
    
    public static func < (lhs: FontNameSuffixEntry, rhs: FontNameSuffixEntry) -> Bool {
        return lhs.index < rhs.index
    }
}


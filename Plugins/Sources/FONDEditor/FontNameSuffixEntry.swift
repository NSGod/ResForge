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

    public static func entries(from styleMappingTable: FOND.StyleMappingTable, manager: RFEditorManager) -> [FontNameSuffixEntry] {
        let suffixSubtable = styleMappingTable.fontNameSuffixSubtable
        var postScriptNamesToSfntResIDs: [String: Int] = [:]
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
            /// Only create an entry that actually references a font if
            /// the entry index is a valid, used index in the style-mapping tables `indexes` table.
            /// For example, take Helvetica, whose base-name string is "Helvetica" at Index 1. The plain
            /// style will reference index 1 ("Helvetica") and the 533 name will be "Helve".
            /// In contrast, Adobe Garamond's base-name string is "AGaramond" at Index 1. The plain style
            /// will instead reference Index 2 ("AGaramond-Regular") and the 533 name will be "AGarReg".
            if styleMappingTable.validIndexes.contains(entry.index) {
                /// first look for an 'sfnt' with this PostScript name
                if let sfntResID = postScriptNamesToSfntResIDs[entry.postScriptName] {
                    entry.sfntResID = ResID(sfntResID)
                } else {
                    /// Otherwise, try to locate the 'LWFN' font file in the same directory as the font suitcase
                    let fontFileName = MD533Filename(forPostScriptFontName: entry.postScriptName)
                    entry.lwfnFilename = fontFileName
                    entry.lwfnURL = docDirURL?.appendingPathComponent(fontFileName)
                }
            }
            entries.append(entry)
        }

        /// Referring to the example given in the diagram at the top of `FontNameSuffixEntry.swift`,
        /// reconstruct entries for the remaining Indexes 9-12 which aren't
        /// present in `entryIndexesToPostScriptNames`
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


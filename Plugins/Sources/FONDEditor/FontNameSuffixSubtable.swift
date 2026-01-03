//
//  FontNameSuffixSubtable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/24/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=490

///       Index     Contents
///       1         \pExampleFont
///       2         0x02 0x09 0x0A
///       3         0x02 0x09 0x0B
///       4         0x03 0x09 0x0A 0x0B
///       5         0x02 0x09 0x0C
///       6         0x04 0x09 0x0C 0x09 0x0A
///       7         0x04 0x09 0x0C 0x09 0x0B
///       8         0x05 0x09 0x0C 0x09 0x0A 0x0B
///       9         \p-
///       10        \pBold
///       11        \pOblique
///       12        \pNarrow
///
///       While indexes 1, 9, 10, 11, & 12 are all valid (Pascal) strings, 2-8 aren't really
///       strings in the usual sense. Instead, they describe how to generate the
///       names for different styles. For example, Index 2 describes how to generate
///       the Bold style PostScript name:
///                 0x02 is the Pascal string length byte, so 2 more bytes follow
///                 0x09 is a reference to index 9, or "-"
///                 0x0A is a reference to index 10, or "Bold"
///       So, the full PostScript name for the bold style is ExampleFont-Bold
///

import Foundation
import RFSupport


struct FontNameSuffixSubtable {
    var stringCount:                            Int16

    var baseFontName:                           String      // Index 1 shown above

    private var entryIndexesToPostScriptNames:  [UInt8: String]
    private var _actualStringCount:             Int16
}

// of all the FOND tables, this is the one I've encountered the most variation and issues with, hence all the debug logging
extension FontNameSuffixSubtable {
    init(_ reader: BinaryDataReader, range knownRange: NSRange) throws {
        stringCount = try reader.read()
        baseFontName = try reader.readPString()
        entryIndexesToPostScriptNames = [:]
        _actualStringCount = 1
        var stringDatas : [Data] = []

        /// we already have the base font name, so go with `stringCount - 1`
        for _ in 0..<stringCount - 1 {
            if NSMaxRange(knownRange) == reader.position {
                NSLog("\(type(of: self)).\(#function)() *** NOTICE: appear to have hit end of data; breaking")
                break
            }
            var length: UInt8 = 0
            do {
                length = try reader.peek()
            } catch {
                NSLog("\(type(of: self)).\(#function)() *** WARNING: hit end of data; breaking...")
                break
            }
            if length == 0 {
                NSLog("\(type(of: self)).\(#function)() *** NOTICE: next length is 0; breaking...")
                break
            }
            let data = try reader.readData(length: Int(length + 1))
            stringDatas.append(data)
            _actualStringCount += 1
        }

        if _actualStringCount != stringCount {
            NSLog("\(type(of: self)).\(#function)() *** WARNING: string count of \(stringCount) (byte-swapped: \(stringCount.byteSwapped)) appears to be wrong; actual string count: \(_actualStringCount)")
        }

        /// Referring to the diagram at the top of this file, we're going to create a representation
        /// where Indexes 2-8 are fully expanded into the full PostScript names.
        /// We won't bother filling in 9 - 12 since they're no longer needed
        entryIndexesToPostScriptNames[1] = baseFontName

        var done = false
        for i in 0..<Int(_actualStringCount) - 1 {
            var fullName = baseFontName
            let entryData = stringDatas[i]
            let length: UInt8 = entryData[0]
            /// now parse the index entries in the string, starting at index 1 (since index 0 is
            /// the length byte of the Pascal string)
            for j in 1..<Int(length) {
                /// we need to subtract 2 here because:
                /// a) these are 1-indexed rather than 0-indexed, and
                /// b) we don't have baseFontName included, which would be the first item
                let nameIndex: UInt8 = entryData[j] - 2
                if nameIndex > _actualStringCount {
                    // we're probably at the end of the index entry strings and at the start of the actual name strings
                    // FIXME: is there a better way for this?
                    done = true
                    break
                }
                let suffix = try stringFromPString(with: stringDatas[Int(nameIndex)])
                fullName += suffix
            }
            if done {
                break
            }
            entryIndexesToPostScriptNames[UInt8(i) + 2] = fullName
        }
        NSLog("\(type(of: self)).\(#function)() entryIndexesToPostScriptNames == \(entryIndexesToPostScriptNames)")
    }

    func postScriptNameForFontEntry(at oneBasedIndex: UInt8) -> String? {
        if oneBasedIndex > _actualStringCount {
            NSLog("\(type(of: self)).\(#function)() *** WARNING: fontEntryIndex of \(oneBasedIndex) is beyond total string count (\(_actualStringCount))")
            return nil
        }
        return entryIndexesToPostScriptNames[oneBasedIndex]
    }

    private func stringFromPString(with data: Data) throws -> String {
        let length = data.withUnsafeBytes {
            $0.loadUnaligned(as: UInt8.self)
        }
        guard length > 0 else {
            return ""
        }
        guard data.count > 1 else {
			return ""
        }
        guard let string = String(data: data[data.startIndex+1..<data.endIndex], encoding: .macOSRoman) else {
            throw BinaryDataReaderError.stringDecodeFailure
        }
        return string
    }

}

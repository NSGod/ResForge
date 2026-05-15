//
//  FontNameSuffixSubtable.swift
//  CoreFont
//
//  Created by Mark Douma on 12/24/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=490

import Foundation
import RFSupport
import OrderedCollections
///    Diagram of the font name suffix subtable structure:
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
///       names for different styles (I'll refer to them hereafter as "index entry strings").
///       For example, Index 2 describes how to generate the Bold style PostScript name:
///                 `0x02` is the Pascal string length byte, so 2 more bytes follow,
///                 `0x09` is a reference to index 9, or "-",
///                 `0x0A` is a reference to index 10, or "Bold"
///       So, the full PostScript name for the bold style is `ExampleFont-Bold`
///

extension FOND {

    // of all the FOND tables, this is the one I've encountered the most variation and issues with, hence all the debug logging
    public final class FontNameSuffixSubtable: ResourceNode {
        public var stringCount:                     Int16           /// actual string count (including `baseFontName`)
        public var baseFontName:                    String          /// Index 1 shown above
                                                                    /// - Note: this is documented as always being a 256 byte-long Pascal string,
                                                                    ///   but that is not the case.
        public private(set) var stringDatas:        [Data]

        // MARK: - AUX:
        public private(set) var entryIndexesToPostScriptNames:  [UInt8: String]
        private var _actualStringCount:             Int16           /// actual actual string count

        private var styles:                         [MacFontStyle]!
        private var stylesToIndexes:                [MacFontStyle: Int]!
        private var entriesAndStrings:              [AnyObject] = []

        var indexes:                                [UInt8] = Array(repeating: 1, count: 48) /// [48]

        public override var totalNodeLength: Int {
            return MemoryLayout<Int16>.size + baseFontName.count + 1 + stringDatas.map(\.count).reduce(0, +)
        }

        public init(_ reader: BinaryDataReader?, range knownRange: NSRange? = nil, options: FontCreationOptions? = nil) throws {
            if let reader, let knownRange {
                stringCount = try reader.read()
                baseFontName = try reader.readPString()
                entryIndexesToPostScriptNames = [:]
                _actualStringCount = 1
                stringDatas = []
                /// we already have the base font name, so go with `stringCount - 1`
                for _ in 0..<stringCount - 1 {
                    if NSMaxRange(knownRange) == reader.bytesRead {
                        NSLog("\(type(of: self)).\(#function) *** NOTICE: appear to have hit end of data; breaking")
                        break
                    }
                    var length: UInt8 = 0
                    do {
                        length = try reader.peek()
                    } catch {
                        NSLog("\(type(of: self)).\(#function) *** WARNING: hit end of data; breaking...")
                        break
                    }
                    if length == 0 {
                        NSLog("\(type(of: self)).\(#function) *** NOTICE: next length is 0; breaking...")
                        break
                    }
                    let data = try reader.readData(length: Int(length + 1))
                    stringDatas.append(data)
                    _actualStringCount += 1
                }
                if _actualStringCount != stringCount {
                    // I've encountered weird values here, hence the logging...
                    NSLog("\(type(of: self)).\(#function) *** WARNING: string count of \(stringCount) (byte-swapped: \(stringCount.byteSwapped)) appears to be wrong; actual string count: \(_actualStringCount)")
                    stringCount = _actualStringCount
                }

                /// Referring to the diagram at the top of this file, we're going to create a representation
                /// where Indexes 2-8 are fully expanded into the full PostScript names.
                /// We won't bother filling in 9 - 12 since they'll no longer be needed
                entryIndexesToPostScriptNames[1] = baseFontName

                var done = false
                for i in 0..<Int(_actualStringCount) - 1 {
                    var fullName = baseFontName
                    let entryData = stringDatas[i]
                    let length: UInt8 = entryData[entryData.startIndex]

                    /// now parse the index entries in the string, starting at index 1 (since index 0 is
                    /// the length byte of the Pascal string)
                    for j in 1...Int(length) {
                        /// we need to subtract 2 here because:
                        /// a) these are 1-indexed rather than 0-indexed, and
                        /// b) we don't have baseFontName included, which would be the first item
                        let nameIndex: UInt8 = entryData[entryData.startIndex + j] - 2
                        if nameIndex > _actualStringCount {
                            // we're probably at the end of the index entry strings and at the start of the actual name strings
                            // FIXME: is there a better way for this?
                            done = true
                            break
                        }
                        let suffix = try Self.stringFromPString(with: stringDatas[Int(nameIndex)])
                        fullName += suffix
                    }
                    if done {
                        break
                    }
                    entryIndexesToPostScriptNames[UInt8(i) + 2] = fullName
                }
            } else if let options {
                stringCount = 1
                _actualStringCount = 1
                baseFontName = options.fontFile.postScriptName
                entryIndexesToPostScriptNames = [1: baseFontName]
                stringDatas = []
            } else {
                throw FONDError.creationError("No options provided")
            }
            // NSLog("\(type(of: self)).\(#function) entryIndexesToPostScriptNames == \(entryIndexesToPostScriptNames)")
        }

        public override func write(to handle: DataHandle, offset: Int? = nil) throws {
            assert(offset == nil)
            /// `stringCount` is corrected in reading in `init()` above, if necessary
            handle.write(stringCount)
            try handle.writePString(baseFontName)
            stringDatas.forEach { handle.writeData($0) }
        }

        public func add(_ fontFile: OTFFontFile, existingFontFiles: [OTFFontFile]) throws {
            var fontFiles = existingFontFiles + [fontFile]
            fontFiles.sort { lhs, rhs in
                return lhs.macStyle < rhs.macStyle
            }
            styles = fontFiles.compactMap(\.macStyle).sorted(by: >)
            indexes = Array(repeating: 1, count: 48)
            entriesAndStrings = Entry.entries(with: fontFiles)
            var styleNames = OrderedSet<StyleString>()
            for entry in entriesAndStrings {
                styleNames.append(contentsOf: (entry as! Entry).styleNames)
            }
            entriesAndStrings.append(contentsOf: Array(styleNames))
            baseFontName = ""
            var i = 1
            entriesAndStrings.forEach {
                if let entry = $0 as? Entry {
                    if baseFontName.isEmpty {
                        baseFontName = entry.baseFontName
                    }
                    entry.index = i
                    entryIndexesToPostScriptNames[UInt8(i)] = i == 1 ? baseFontName : entry.fontFile!.postScriptName
                } else {
                    ($0 as! StyleString).index = i
                }
                i += 1
            }
            stringCount = Int16(entriesAndStrings.count)
            _actualStringCount = stringCount
            stringDatas = []
            stylesToIndexes = [:]
            entriesAndStrings.forEach {
                if let entry = $0 as? Entry {
                    if !entry.isBaseFontName {
                        stringDatas.append(entry.stringData)
                        stylesToIndexes[entry.fontFile!.macStyle.abridged()] = entry.index
                    }
                } else {
                    stringDatas.append(($0 as! StyleString).stringData)
                }
            }
            for styleIndex: UInt16 in 0..<48 {
                let style = MacFontStyle(rawValue: styleIndex, isAbridged: true)
                let bestStyleMatch = style.closestMatch(in: styles)
                indexes[Int(styleIndex)] = UInt8(stylesToIndexes[bestStyleMatch] ?? 1)
            }
        }

        public func postScriptNameForFontEntry(at oneBasedIndex: UInt8) -> String? {
            if oneBasedIndex > _actualStringCount {
                NSLog("\(type(of: self)).\(#function) *** WARNING: fontEntryIndex of \(oneBasedIndex) is beyond total string count (\(_actualStringCount))")
                return nil
            }
            return entryIndexesToPostScriptNames[oneBasedIndex]
        }

        static func pascalStringData(from string: String) throws -> Data {
            guard let encoded = string.data(using: .macOSRoman), encoded.count <= UInt8.max else {
                throw FONDError.creationError("Failed to encode pascal string data for \(string)")
            }
            var encodedData = Data()
            encodedData.append(UInt8(encoded.count))
            encodedData.append(encoded)
            return encodedData
        }

        public static func stringFromPString(with data: Data) throws -> String {
            let length = data.withUnsafeBytes {
                $0.loadUnaligned(as: UInt8.self)
            }
            guard length > 0 else { return "" }
            guard data.count > 1 else { return "" }
            guard let string = String(data: data[data.startIndex+1..<data.endIndex], encoding: .macOSRoman) else {
                throw BinaryDataReaderError.stringDecodeFailure
            }
            return string
        }
    }
}

public extension FOND.FontNameSuffixSubtable {

    final class Entry {
        weak var fontFile:  OTFFontFile?
        let baseFontName:   String
        var styleName:      String  = ""
        var styleNames:     [StyleString] = []
        var index:          Int = 0

        var stringData:     Data {
            let stringData: [UInt8] = styleNames.map { UInt8($0.index) }
            return Data([UInt8(styleNames.count)] + stringData)
        }

        var isBaseFontName: Bool { styleName.isEmpty && fontFile == nil }

        init(fontFile: OTFFontFile?, baseFontName: String) {
            self.fontFile = fontFile
            self.baseFontName = baseFontName
            // FIXME: be able to deal with a leading - in the name
            if let psName = fontFile?.postScriptName, psName.hasPrefix(baseFontName) {
                styleName = String(psName.dropFirst(baseFontName.count))
                styleNames = styleName.splitCamelCase().map { .init(string: $0) }
            }
        }

        static func entries(with fontFiles: [OTFFontFile]) -> [Entry] {
            guard !fontFiles.isEmpty else { return [] }
            var fontFiles = fontFiles
            fontFiles.sort {
                $0.macStyle < $1.macStyle
            }
            let psNames = fontFiles.map(\.postScriptName)
            var commonPrefix = fontFiles.first!.postScriptName
            for psName in psNames {
                commonPrefix = psName.commonPrefix(with: commonPrefix)
            }
            var entries = [Entry]()
            if fontFiles.count > 0 && commonPrefix != fontFiles.first!.postScriptName {
                let entry = Entry(fontFile: nil, baseFontName: commonPrefix)
                entries.append(entry)
            }
            entries.append(contentsOf: fontFiles.map { Entry(fontFile: $0, baseFontName: commonPrefix) })
            var i = 1
            entries.forEach { $0.index = i; i += 1 }
            return entries
        }
    }

    final class StyleString: Equatable, Hashable {
        let string:     String
        var index:      Int

        var stringData: Data {
            do {
                return try FOND.FontNameSuffixSubtable.pascalStringData(from: string)
            } catch {
                NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
                return Data()
            }
        }

        init(string: String, index: Int = 1) {
            self.string = string
            self.index = index
        }

        public static func == (lhs: StyleString, rhs: StyleString) -> Bool {
            return lhs.string == rhs.string && lhs.index == rhs.index
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(string)
            hasher.combine(index)
        }
    }
}


fileprivate extension String {

    func splitCamelCase() -> [String] {
        return self.reduce(into: [String]()) { styleNames, character in
            if character.isUppercase, !styleNames.isEmpty {
                styleNames.append(String(character))
            } else {
                if styleNames.isEmpty {
                    styleNames.append(String(character))
                } else {
                    styleNames[styleNames.count - 1].append(character)
                }
            }
        }
    }
}

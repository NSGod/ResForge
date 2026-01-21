//
//  KernTable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/23/2025.
//
//  https://developer.apple.com/library/archive/documentation/mac/pdf/Text.pdf#page=494

import Foundation
import RFSupport
import CoreFont
import CSV

final class KernTable: FONDResourceNode {
    var numberOfEntries:                Int16              // number of entries - 1
    var entries:                        [KernTableEntry]

    var hasOutOfRangeCharCodes:         Bool = false
    private var fontStylesToEntries:    [MacFontStyle: KernTableEntry]

    @objc override var length:          Int {
        get {
            var length = MemoryLayout<Int16>.size
            for entry in self.entries { length += entry.length }
            return length
        }
        set {}
    }

    init(_ reader: BinaryDataReader, fond: FOND) throws {
        numberOfEntries = try reader.read()
        entries = []
        fontStylesToEntries = [:]
        for _ in 0...numberOfEntries {
            let entry = try KernTableEntry(reader, fond: fond)
            entries.append(entry)
            fontStylesToEntries[entry.style] = entry
            hasOutOfRangeCharCodes = hasOutOfRangeCharCodes ? true : entry.hasOutOfRangeCharCodes
        }
        super.init(fond:fond)
    }

    func entry(for fontStyle: MacFontStyle) -> KernTableEntry? {
        return fontStylesToEntries[fontStyle]
    }
}


// MARK: -
final class KernTableEntry: FONDResourceNode {
    var style:              MacFontStyle            // style this entry applies to

    /// NOTE: While `numKerns` is defined as a `SInt16`, it makes no sense to have negative kern pairs,
    ///       and I *have* encountered fonts that have more than 32,767 kern pairs, so make it an `UInt16`
    ///
    var numKerns:           UInt16  /// Number of kern entries that follow (and NOT the entryLength/length
                                    /// of the data that follows this struct as is documented).

    var kernPairs:          [KernPair]

    // MARK: AUX
    var hasOutOfRangeCharCodes: Bool = false

    @objc var objcStyle:    MacFontStyle.RawValue {
        didSet { style = .init(rawValue: objcStyle) }
    }
    
    override var length:    Int {
        get { return MemoryLayout<UInt16>.size * 2 + Int(numKerns) * KernPair.length }
        set {}
    }

    static let GPOSFeatureFileType: String = NSLocalizedString("'GPOS' Feature File", comment: "")
    static let GPOSFeatureUTType:   String = kUTTypeUTF8PlainText as String
    static let CSVFileType:         String = NSLocalizedString("Comma-Separated Variables (CSV)", comment: "")
    static let CSVUTType:           String = kUTTypeCommaSeparatedText as String

    init(_ reader: BinaryDataReader, fond: FOND) throws {
        style = try reader.read()
        objcStyle = style.rawValue
        numKerns = try reader.read()
        kernPairs = []
        for _ in 0..<numKerns {
            let kernPair: KernPair = try KernPair(reader)
            kernPairs.append(kernPair)
            hasOutOfRangeCharCodes = hasOutOfRangeCharCodes ? true : kernPair.hasOutOfRangeCharCodes
        }
        super.init(fond: fond)
    }

    public struct KernExportConfig {
        public enum Format {
            case GPOS
            case CSV
        }
        public static let gposDefault: KernExportConfig = .init()
        public static let csvDefault: KernExportConfig = .init()

        public var format:              Format = .GPOS
        public var resolveGlyphNames:   Bool = true
        public var scaleToUnitsPerEm:   Bool = true

        public var pathExtension: String {
            switch format {
                case .GPOS: return "txt"
                case .CSV: return "csv"
            }
        }
    }

    public func representation(using config: KernExportConfig = .gposDefault) -> String? {
        if config.format == .GPOS {
            return GPOSFeatureRepresentation(using: config)
        } else {
            return CSVRepresentation(using: config)
        }
    }

    // FIXME: add better explanation about what this method is for
    /* This can be used to create a `feature` file used during conversion to OTF/TTF
        by Adobe AFDKO's hotconvert/makeotf to create a `GPOS` table containing the kern pairs */
    public func GPOSFeatureRepresentation(using config: KernExportConfig = .gposDefault) -> String? {
        var mString = """
languagesystem DFLT dflt;
languagesystem latn dflt;

feature kern {\n
"""
//        var mString = "feature kern {\n"
        var mKernPairStrings: [String] = []
        let unitsPerEm = self.fond.unitsPerEm(for: style)
        for kernPair in kernPairs {
            let firstGlyphName = config.resolveGlyphNames ? self.fond.glyphName(for: kernPair.kernFirst) : String(kernPair.kernFirst)
            let secondGlyphName = config.resolveGlyphNames ? self.fond.glyphName(for: kernPair.kernSecond) : String(kernPair.kernSecond)
            /* In cases where this FOND and kern pairs reference a PostScript outline font rather than TT,
               I'd normally parse that Mac PostScript font file and check to make sure its encoding agrees
               with the glyph names the FOND's encoding assigned, but, that's a bit outside the scope
               of this editor. */
            let value: Int16 = config.scaleToUnitsPerEm ? Int16(lround(Fixed4Dot12ToDouble(kernPair.kernWidth) * Double(unitsPerEm.rawValue))) : kernPair.kernWidth
            if let firstGlyphName, let secondGlyphName {
                mKernPairStrings.append("\tpos \(firstGlyphName) \(secondGlyphName) \(value);")
            } else {
                NSLog("\(type(of: self)).\(#function)() *** ERROR failed to get glyphNames for charCodes: \(kernPair.kernFirst), \(kernPair.kernSecond)")
            }
        }
        mKernPairStrings.sort(by: { $0.localizedStandardCompare($1) == .orderedAscending })
        mString += mKernPairStrings.joined(separator: "\n")
        mString += "} kern;\n"
        return mString
    }

    public func CSVRepresentation(using config: KernExportConfig = .csvDefault) -> String? {
        let stream = OutputStream(toMemory: ())
        do {
            let writer = try CSVWriter(stream: stream)
            try writer.write(row: ["Kern First", "Kern Second", "Kern Width"])
            let unitsPerEm = self.fond.unitsPerEm(for: style)
            for kernPair in kernPairs {
                guard let firstGlyphName = config.resolveGlyphNames ? self.fond.glyphName(for: kernPair.kernFirst) : String(kernPair.kernFirst) else {
                    continue
                }
                guard let secondGlyphName = config.resolveGlyphNames ? self.fond.glyphName(for: kernPair.kernSecond) : String(kernPair.kernSecond) else {
                    continue
                }
                /* In cases where this FOND and kern pairs reference a PostScript outline font rather than TT,
                   I'd normally parse that Mac PostScript font file and check to make sure its encoding agrees
                   with the glyph names the FOND's encoding assigned, but, that's a bit outside the scope
                   of this editor. */
                let value: Int16 = config.scaleToUnitsPerEm ? Int16(lround(Fixed4Dot12ToDouble(kernPair.kernWidth) * Double(unitsPerEm.rawValue))) : kernPair.kernWidth
                try writer.write(row: [firstGlyphName, secondGlyphName, String(value)])
            }
            writer.stream.close()
        } catch {
             NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
        if let data = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}


// MARK: - KernPair
struct KernPair: Equatable, CustomStringConvertible {
    var kernFirst:  UInt8           // 1st character of kerned pair
    var kernSecond: UInt8           // 2nd character of kerned pair
    var kernWidth:  Fixed4Dot12     // kerning distance, in pixels, for the 2 glyphs at size of 1pt; fixed-point 4.12 format

    var hasOutOfRangeCharCodes: Bool {
        // FIXME: this is no longer true for the "enhanced/expanded" macRomanEncoding?
        return kernFirst < 0x20 || kernSecond < 0x20 || kernFirst == 0x7F || kernSecond == 0x7F
    }

    /// bare-bones `description` that doesn't try to resolve glyph names or factor in unitsPerEm
    var description: String {
        return "\(kernFirst), \(kernSecond), \(Fixed4Dot12ToDouble(kernWidth))"
    }

    static func == (lhs: KernPair, rhs: KernPair) -> Bool {
        return lhs.kernFirst == rhs.kernFirst && lhs.kernSecond == rhs.kernSecond && lhs.kernWidth == rhs.kernWidth
    }
}

extension KernPair {
    static var length: Int {
        return MemoryLayout<UInt8>.size * 2 + MemoryLayout<Fixed4Dot12>.size // 4
    }

    init(_ reader: BinaryDataReader) throws {
        kernFirst = try reader.read()
        kernSecond = try reader.read()
        kernWidth = try reader.read()
    }
}

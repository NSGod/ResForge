//
//  KernPairExporter.swift
//  FONDEditor
//
//  Created by Mark Douma on 2/17/2026.
//

import Foundation
import RFSupport
import CoreFont
import CSV

public class KernPairExporter {
    public static let GPOSFeatureFileType: String = NSLocalizedString("'GPOS' Feature File", comment: "")
    public static let GPOSFeatureUTType:   String = kUTTypePlainText as String
    public static let CSVFileType:         String = NSLocalizedString("Comma-Separated Variables (CSV)", comment: "")
    public static let CSVUTType:           String = kUTTypeCommaSeparatedText as String

    public struct Config {
        public enum Format {
            case GPOS
            case CSV
        }
        public static let gposDefault: Config = .init(format: .GPOS, resolveGlyphNames: true, scaleToUnitsPerEm: true)
        public static let csvDefault: Config = .init(format: .CSV, resolveGlyphNames: true, scaleToUnitsPerEm: true)

        public var format:              Format = .GPOS
        public var resolveGlyphNames:   Bool = true
        public var scaleToUnitsPerEm:   Bool = true

        public var pathExtension: String {
            switch format {
                case .GPOS: return "txt"
                case .CSV: return "csv"
            }
        }

        public init(format: Format, resolveGlyphNames: Bool, scaleToUnitsPerEm: Bool) {
            self.format = format
            self.resolveGlyphNames = resolveGlyphNames
            self.scaleToUnitsPerEm = scaleToUnitsPerEm
        }
    }

    // feeding in the RFEditorManager will allow for a much better scaling to Units Per Em
    public static func representation(of entry: FOND.KernTable.Entry, using config: Config = .gposDefault, manager: RFEditorManager? = nil) -> String? {
        if config.format == .GPOS {
            return GPOSFeatureRepresentation(of: entry, using: config, manager: manager)
        } else {
            return CSVRepresentation(of: entry, using: config, manager: manager)
        }
    }

    // FIXME: add better explanation about what this method is for
    /* This can be used to create a `feature` file used during conversion to OTF/TTF
        by Adobe AFDKO's hotconvert/makeotf to create a `GPOS` table containing the kern pairs */
    public static func GPOSFeatureRepresentation(of entry: FOND.KernTable.Entry, using config: Config = .gposDefault, manager: RFEditorManager? = nil) -> String? {
        var mString = """
languagesystem DFLT dflt;
languagesystem latn dflt;

feature kern {\n
"""
        var mKernPairStrings: [String] = []
        let unitsPerEm = entry.fond.unitsPerEm(for: entry.style, manager: manager)
        for kernPair in entry.kernPairs {
            let firstGlyphName = config.resolveGlyphNames ? entry.fond.glyphName(for: kernPair.kernFirst) : String(kernPair.kernFirst)
            let secondGlyphName = config.resolveGlyphNames ? entry.fond.glyphName(for: kernPair.kernSecond) : String(kernPair.kernSecond)
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
        mString += "\n} kern;\n"
        return mString
    }

    public static func CSVRepresentation(of entry: FOND.KernTable.Entry, using config: Config = .csvDefault, manager: RFEditorManager? = nil) -> String? {
        let stream = OutputStream(toMemory: ())
        do {
            let writer = try CSVWriter(stream: stream)
            try writer.write(row: ["Kern First", "Kern Second", "Kern Width"])
            let unitsPerEm = entry.fond.unitsPerEm(for: entry.style, manager: manager)
            for kernPair in entry.kernPairs {
                guard let firstGlyphName = config.resolveGlyphNames ? entry.fond.glyphName(for: kernPair.kernFirst) : String(kernPair.kernFirst) else {
                    continue
                }
                guard let secondGlyphName = config.resolveGlyphNames ? entry.fond.glyphName(for: kernPair.kernSecond) : String(kernPair.kernSecond) else {
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

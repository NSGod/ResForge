//
//  Styl.swift
//  CoreFont
//
//  Created by Mark Douma on 5/26/2026.
//

import Cocoa
import RFSupport

/// represents a `styl` resource

extension ResourceType {
    public static let styl = ResourceType("styl")
}

public final class Styl: CFResource {
    public var numRuns:     Int = 0
    public var runs:        [Run] = [] {
        didSet { numRuns = runs.count }
    }

    public var resource:    Resource
    private var reader:     BinaryDataReader

    public init(with resource: Resource, count textCount: Int) throws {
        self.resource = resource
        reader = BinaryDataReader(resource.data)
        if reader.data.isEmpty { return }
        numRuns = Int(try reader.read() as Int16)
        runs = try (0..<numRuns).map { _ in try Run(reader, count: textCount) }
    }

    public func data() throws -> Data {
        let handle = DataHandle()
        numRuns = runs.count
        handle.write(Int16(numRuns))
        try runs.forEach { try $0.write(to: handle) }
        return handle.data
    }
}

extension Styl {

    // MARK: -
    /// represents a style run that's stored in a `Styl` resource
    public final class Run: DataHandleWriting, Equatable {
        public var startOffset:     Int = 0                     /// Int32
        public var lineHeight:      Int = 0                     /// Int16
        public var fontAscent:      Int = 0                     /// Int16
        public var fontFamilyID:    ResID = 0                   /// Int16
        public var fontStyle:       MacFontStyle = .regular     /// UInt16 (little-endian; actually, UInt8 + UInt8 of padding)
        public var fontPointSize:   Int = 0                     /// UInt16
        public var rgbColor:        RGBColor                    /// 6

        // MARK: AUX
        public var style:           Style {
            return Style(fontFamilyID: fontFamilyID, fontStyle: fontStyle, fontPointSize: fontPointSize, color: rgbColor.color)
        }

        public var range:           NSRange = NSRange(location: 0, length: 0)

        public static var nodeLength: Int { 20 }

        public init(_ reader: BinaryDataReader, count textCount: Int) throws {
            startOffset = Int(try reader.read() as Int32)
            lineHeight = Int(try reader.read() as Int16)
            fontAscent = Int(try reader.read() as Int16)
            fontFamilyID = try reader.read()
            fontStyle = try reader.read(bigEndian: false)
            fontPointSize = Int(try reader.read() as UInt16)
            rgbColor = try RGBColor(reader)
            reader.pushSavedPosition()
            var endOffset = 0
            if let nextStartOffset: Int32 = try? reader.read() {
                endOffset = Int(nextStartOffset)
            } else {
                endOffset = textCount
            }
            reader.popPosition()
            range = NSMakeRange(startOffset, endOffset - startOffset)
        }

        public init(style: Style, range: NSRange) {
            self.startOffset = range.location
            if let font: NSFont = style.attrs[.font] as? NSFont {
                lineHeight = Int(font.ascender - font.descender + font.leading)
                fontAscent = Int(font.ascender)
            }
            self.fontFamilyID = style.fontFamilyID
            self.fontStyle = style.fontStyle
            self.fontPointSize = style.fontPointSize
            self.rgbColor = style.color.rgbColor
        }

        public func write(to handle: DataHandle, offset: Int? = 0) throws {
            assert(offset == 0)
            handle.write(Int32(startOffset))
            handle.write(Int16(lineHeight))
            handle.write(Int16(fontAscent))
            handle.write(ResID(fontFamilyID))
            handle.write(fontStyle, bigEndian: false)
            handle.write(UInt16(fontPointSize))
            try rgbColor.write(to: handle)
        }

        public func canMerge(with other: Run) -> Bool {
            return lineHeight == other.lineHeight &&
            fontAscent == other.fontAscent &&
            fontFamilyID == other.fontFamilyID &&
            fontStyle == other.fontStyle &&
            fontPointSize == other.fontPointSize &&
            rgbColor == other.rgbColor
        }

        public func merge(with other: Run) {
            assert(canMerge(with: other))
            startOffset = min(startOffset, other.startOffset)
        }

        public static func == (lhs: Run, rhs: Run) -> Bool {
            return lhs.startOffset == rhs.startOffset &&
            lhs.lineHeight == rhs.lineHeight &&
            lhs.fontAscent == rhs.fontAscent &&
            lhs.fontFamilyID == rhs.fontFamilyID &&
            lhs.fontStyle == rhs.fontStyle &&
            lhs.fontPointSize == rhs.fontPointSize &&
            lhs.rgbColor == rhs.rgbColor
        }
    }
}

//
//  Sbit.BitmapGlyph.swift
//  CoreFont
//
//  Created by Mark Douma on 3/29/2026.
//

import Cocoa
import RFSupport

extension Sbit {

    /// in `bdat`/`EBDT` table
    public final class BitmapGlyph: Node, Comparable, FontAwaking {
        public var glyphID:             GlyphID = 0
        public var data:                Data?
        public var glyphRect:           NSRect = .zero
        public var advanceWidth:        CGFloat = 0
        public var boundingBox:         NSRect = .zero

        public var metrics:             GlyphMetrics!

        public weak var strike:         BitmapStrike!

        public var imageFormat:         GlyphImageFormat

        public var numComponents:       UInt16?
        public var components:          [Component]?

        public lazy var image:          NSImage? = {
            // FIXME: allow data == nil for .componentSmall && .componentBig
            // FIXME: add support for generating image using components
            guard let metrics, let data else { return nil }
            let bytesPerRow = (Int(NSWidth(boundingBox)) + 7)/8
            guard let bitmapImageRep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                                        pixelsWide: Int(NSWidth(boundingBox)),
                                                        pixelsHigh: Int(NSHeight(boundingBox)),
                                                        bitsPerSample: Int(strike.sizeTable.bitDepth.rawValue),
                                                        samplesPerPixel: 1,
                                                        hasAlpha: false,
                                                        isPlanar: false,
                                                        colorSpaceName: .calibratedWhite,
                                                        bytesPerRow:bytesPerRow,
                                                        bitsPerPixel: Int(strike.sizeTable.bitDepth.rawValue)) else {
                return nil
            }
            let length = bitmapImageRep.bytesPerRow * bitmapImageRep.pixelsHigh
            let bitmapData = bitmapImageRep.bitmapData!
            if imageFormat.isByteAligned {
                data.copyBytes(to: bitmapData, count: length)
            } else if imageFormat.isBitAligned {
                /// Each row is bit-aligned, but each glyph is byte-aligned
                let length = ((Int(metrics.height) * Int(metrics.width)) + 7)/8
                for i in 0..<length {
                    for ch in data {
                        for j in 0..<8 {
                            let l = (i * 8 + j) / Int(metrics.width)
                            let p = (i * 8 + j) % Int(metrics.width)
                            if l < metrics.height && (ch & (1 << (7 - j))) != 0 {
                                bitmapData[Int(l) * bytesPerRow + Int(p >> 3)] |= (1 << (7-(p & 7)))
                            }
                        }
                    }
                }
            }
            // invert bits
            for i in 0..<length {
                bitmapData[i] ^= 0xFF
            }
            // FIXME: maybe switch to grayscale or something less costly?
            let srgb = CGColorSpace(name: CGColorSpace.sRGB)!
            let context = CGContext(data: nil,
                                    width: Int(NSWidth(boundingBox)),
                                    height: Int(NSHeight(boundingBox)),
                                    bitsPerComponent: 8,
                                    bytesPerRow: Int(NSWidth(boundingBox)) * 4,
                                    space: srgb,
                                    bitmapInfo: CGBitmapInfo(alpha: .noneSkipLast))
            let imageRef = bitmapImageRep.cgImage!
            context?.draw(imageRef, in: CGRect(origin: .zero, size: CGSize(width: NSWidth(boundingBox), height: NSHeight(boundingBox))))
            guard let rgbImageRef = context?.makeImage() else { return nil }
            let imageRep = NSBitmapImageRep(cgImage: rgbImageRef)
            let image = NSImage(size: imageRep.size)
            image.addRepresentation(imageRep)
            return image
        }()

        public required init(_ reader: BinaryDataReader, imageDataOffset: UInt32, range: Range<UInt32>, glyphID: GlyphID, imageFormat: GlyphImageFormat, horizontalMetrics: Bool) throws {
            guard imageFormat.isSupported else {
                throw FontTableError.parseError("Unsupported 'bdat' glyph image format \(imageFormat.rawValue)")
            }
            self.glyphID = glyphID
            self.imageFormat = imageFormat
            reader.pushSavedPosition()
            defer { reader.popPosition() }
            try reader.setPosition(imageDataOffset + range.lowerBound)
            if imageFormat.hasSmallMetrics {
                metrics = GlyphMetrics(try SmallGlyphMetrics(reader, isHorizontal: horizontalMetrics))
            } else if imageFormat.hasBigMetrics {
                metrics = GlyphMetrics(try BigGlyphMetrics(reader))
            }
            // FIXME: add support for .componentSmall && .componentBig
            if imageFormat.hasComponents {
                if imageFormat.hasSmallMetrics {
                    /// consume UInt8 padding
                    try reader.advance(1)
                }
                numComponents = try reader.read()
                components = try (0..<numComponents!).map { _ in try Component(reader) }
            } else {
                data = try reader.subdata(with: UInt32(reader.bytesRead)..<(imageDataOffset + range.upperBound))
            }
            try super.init(reader)
        }

        @available(*, unavailable, message: "use init(_:offset:range:glyphID:imageFormat:horizontalMetrics:")
        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            fatalError("use init(_:offset:range:glyphID:imageFormat:horizontalMetrics:")
        }

        public func awakeFromFont() {
            calculateMetrics()
            /// resolve components
            if let components {
                components.forEach { $0.glyph = strike.glyph(for: $0.glyphID) }
            }
        }

        private func calculateMetrics() {
            if let metrics, let strike {
                switch metrics {
                    case .small(let metrics):
                        boundingBox = NSMakeRect(CGFloat(metrics.bearingX), CGFloat(Int(metrics.bearingY) - Int(metrics.height)), CGFloat(metrics.width), CGFloat(metrics.height))
                        glyphRect = NSMakeRect(0, CGFloat(strike.sizeTable.hori.descender), CGFloat(metrics.advance), CGFloat(strike.sizeTable.hori.ascender + abs(strike.sizeTable.hori.descender)))
                        advanceWidth = CGFloat(metrics.advance)
                    case .big(let metrics):
                        boundingBox = NSMakeRect(CGFloat(metrics.horiBearingX), CGFloat(Int(metrics.horiBearingY) - Int(metrics.height)), CGFloat(metrics.width), CGFloat(metrics.height))
                        glyphRect = NSMakeRect(0, CGFloat(strike.sizeTable.hori.descender), CGFloat(metrics.horiAdvance), CGFloat(strike.sizeTable.hori.ascender + abs(strike.sizeTable.hori.descender)))
                        advanceWidth = CGFloat(metrics.horiAdvance)
                }
            }
        }

        public static func < (lhs: BitmapGlyph, rhs: BitmapGlyph) -> Bool {
            lhs.glyphID < rhs.glyphID
        }

        public static func == (lhs: BitmapGlyph, rhs: BitmapGlyph) -> Bool {
            return lhs.glyphID == rhs.glyphID
        }
    }

    /// The last 2 formats (`.componentSmall` (`Format8`) and `.componentBig` (`Format9`) are
    /// generally found only found in Microsoft `EBDT` tables, not in Apple `bdat` tables.
    /// Component glyphs work by combining existing glyphs and applying simple transforms to them
    // MARK: -
    public final class Component: Node {
        public var glyphID:         GlyphID         /// glyphID of component
        public var xOffset:         Int8            /// position of component
        public var yOffset:         Int8            /// position of component

        // MARK: AUX
        public weak var glyph:      BitmapGlyph?    /// existing referenced glyph

        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            glyphID = try reader.read()
            xOffset = try reader.read()
            yOffset = try reader.read()
            try super.init(reader)
        }
    }
}


//
//  Sbit.BitmapGlyph.swift
//  CoreFont
//
//  Created by Mark Douma on 3/29/2026.
//

import Cocoa
import RFSupport

extension Sbit {

    public final class BitmapGlyph: Node, Comparable {
        public var glyphID:             GlyphID = 0

        public var glyphRect:           NSRect = .zero
        public var data:                Data
        public var metrics:             GlyphMetrics!
        public var advanceWidth:        CGFloat = 0

        public weak var strike:         BitmapStrike!

        public lazy var image:          NSImage? = {
            guard let metrics else { return nil }
            guard let bitmapImageRep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                                        pixelsWide: Int(NSWidth(glyphRect)),
                                                        pixelsHigh: Int(NSHeight(glyphRect)),
                                                        bitsPerSample: Int(strike.sizeTable.bitDepth.rawValue),
                                                        samplesPerPixel: 1,
                                                        hasAlpha: false,
                                                        isPlanar: false,
                                                        colorSpaceName: .calibratedWhite,
                                                        bytesPerRow:(Int(NSWidth(glyphRect)) + 7)/8,
                                                        bitsPerPixel: Int(strike.sizeTable.bitDepth.rawValue)) else {
                return nil
            }
            let length = bitmapImageRep.bytesPerRow * bitmapImageRep.pixelsHigh
            let bitmapData = bitmapImageRep.bitmapData!
            data.copyBytes(to: bitmapData, count: length)
            // invert bits
            for i in 0..<length {
                bitmapData[i] ^= 0xFF
            }
            let srgb = CGColorSpace(name: CGColorSpace.sRGB)!
            let context = CGContext(data: nil,
                                    width: Int(NSWidth(glyphRect)),
                                    height: Int(NSHeight(glyphRect)),
                                    bitsPerComponent: 8,
                                    bytesPerRow: Int(NSWidth(glyphRect)) * 4,
                                    space: srgb,
                                    bitmapInfo: CGBitmapInfo(alpha: .noneSkipLast))
            let imageRef = bitmapImageRep.cgImage!
            context?.draw(imageRef, in: CGRect(origin: .zero, size: CGSize(width: NSWidth(glyphRect), height: NSHeight(glyphRect))))
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
            reader.pushSavedPosition()
            defer { reader.popPosition() }
            try reader.setPosition(imageDataOffset + range.lowerBound)
            if imageFormat.hasSmallMetrics {
                metrics = GlyphMetrics(try SmallGlyphMetrics(reader, isHorizontal: horizontalMetrics))
                glyphRect = NSMakeRect(0, 0, CGFloat(metrics.smallMetrics!.width), CGFloat(metrics.smallMetrics!.height))
                advanceWidth = CGFloat(metrics.smallMetrics!.advance)
            } else if imageFormat.hasBigMetrics {
                metrics = GlyphMetrics(try BigGlyphMetrics(reader))
                glyphRect = NSMakeRect(0, 0, CGFloat(metrics.bigMetrics!.width), CGFloat(metrics.bigMetrics!.height))
                advanceWidth = CGFloat(metrics.bigMetrics!.horiAdvance)
            }
            // FIXME: add support for .componentSmall && .componentBig
            data = try reader.subdata(with: UInt32(reader.bytesRead)..<(imageDataOffset + range.upperBound))
            try super.init(reader)
        }

        @available(*, unavailable, message: "use init(_:offset:range:glyphID:imageFormat:horizontalMetrics:")
        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            fatalError("use init(_:offset:range:glyphID:imageFormat:horizontalMetrics:")
        }

        public static func < (lhs: BitmapGlyph, rhs: BitmapGlyph) -> Bool {
            lhs.glyphID < rhs.glyphID
        }

        public static func == (lhs: BitmapGlyph, rhs: BitmapGlyph) -> Bool {
            return lhs.glyphID == rhs.glyphID
        }
    }

    /// these later 2 formats generally only found in `EBDT` tables, not `bdat`s
    // MARK: -
    public final class Component: Node {
        public var glyphID:         GlyphID
        public var xOffset:         Int8
        public var yOffset:         Int8

        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            glyphID = try reader.read()
            xOffset = try reader.read()
            yOffset = try reader.read()
            try super.init(reader)
        }
    }
}


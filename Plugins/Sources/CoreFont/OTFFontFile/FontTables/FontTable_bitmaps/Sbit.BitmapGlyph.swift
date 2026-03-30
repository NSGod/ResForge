//
//  Sbit.BitmapGlyph.swift
//  CoreFont
//
//  Created by Mark Douma on 3/29/2026.
//

import Cocoa
import RFSupport

extension Sbit {

    public final class BitmapGlyph: Node, Comparable, FontAwaking {
        public var glyphID:             GlyphID = 0
        public var glyphRect:           NSRect = .zero
        public var data:                Data?
        public var advanceWidth:        CGFloat = 0

        public var metrics:             GlyphMetrics! {
            didSet {
                if let metrics {
                    switch metrics {
                        case .small(let metrics):
                            glyphRect = NSMakeRect(0, 0, CGFloat(metrics.width), CGFloat(metrics.height))
                            advanceWidth = CGFloat(metrics.advance)
                        case .big(let metrics):
                            glyphRect = NSMakeRect(0, 0, CGFloat(metrics.width), CGFloat(metrics.height))
                            advanceWidth = CGFloat(metrics.horiAdvance)
                    }
                }
            }
        }

        public weak var strike:         BitmapStrike!

        public var imageFormat:         GlyphImageFormat
        public var numComponents:       UInt16?
        public var components:          [Component]?

        public lazy var image:          NSImage? = {
            // FIXME: allow data == nil for .componentSmall && .componentBig
            // FIXME: add support for generating image using components
            guard let metrics, let data else { return nil }
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
            self.imageFormat = imageFormat
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
            if let components {
                components.forEach { $0.glyph = strike.glyph(for: $0.glyphID) }
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
    /// generally found only found in Microsoft `EBDT` tables, not Apple's `bdat`s
    // MARK: -
    public final class Component: Node {
        public var glyphID:         GlyphID         /// glyphID of component
        public var xOffset:         Int8            /// position of component
        public var yOffset:         Int8            /// position of component

        // MARK: AUX
        public weak var glyph:      BitmapGlyph!    // existing referenced glyph

        public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
            glyphID = try reader.read()
            xOffset = try reader.read()
            yOffset = try reader.read()
            try super.init(reader)
        }
    }
}


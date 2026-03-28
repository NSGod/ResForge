//
//  BitmapGlyph.swift
//  CoreFont
//
//  Created by Mark Douma on 3/25/2026.
//

import Cocoa
import RFSupport

public class BitmapGlyph: Node, Comparable {
    public var glyphID:         GlyphID

    public var glyphRect:       NSRect = .zero
    public var data:            Data

    public var metrics:         Sbit.GlyphMetrics! {
        didSet {
            if let metrics {
                switch metrics {
                    case .small(let metrics):
                        glyphRect = NSMakeRect(0, 0, CGFloat(metrics.width), CGFloat(metrics.height))

                    case .big(let metrics):
                        glyphRect = NSMakeRect(0, 0, CGFloat(metrics.width), CGFloat(metrics.height))
                }
            }
        }
    }

    public weak var strike:     BitmapStrike!

    public lazy var image:      NSImage? = {
        guard let metrics else { return nil }
        guard let bitmapImageRep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                                    pixelsWide: Int(NSWidth(glyphRect)),
                                                    pixelsHigh: Int(NSHeight(glyphRect)),
                                                    bitsPerSample: Int(strike.sizeTable.bitDepth.rawValue),
                                                    samplesPerPixel: 1,
                                                    hasAlpha: false,
                                                    isPlanar: false,
                                                    colorSpaceName: .calibratedWhite,
                                                    bytesPerRow:Int(NSWidth(glyphRect)) / 8,
                                                    bitsPerPixel: Int(strike.sizeTable.bitDepth.rawValue)) else {
            return nil
        }
        let length = Int(NSWidth(glyphRect)) * Int(NSHeight(glyphRect)) * Int(strike.sizeTable.bitDepth.rawValue) / 8
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

    public required init(_ reader: BinaryDataReader, offset: UInt32, range: Range<UInt32>, glyphID: GlyphID) throws {
        self.glyphID = glyphID
        data = try reader.subdata(with: (offset + range.lowerBound)..<(offset + range.upperBound))
        try super.init(reader)
    }

    @available(*, unavailable, message: "Use init(_:offset:range:glyphID:) instead")
    public required init(_ reader: BinaryDataReader, offset: Int? = nil) throws {
        fatalError("Use init(_:offset:range:glyphID:) instead")
    }

    public static func < (lhs: BitmapGlyph, rhs: BitmapGlyph) -> Bool {
        lhs.glyphID < rhs.glyphID
    }

    public static func == (lhs: BitmapGlyph, rhs: BitmapGlyph) -> Bool {
        return lhs.glyphID == rhs.glyphID
    }
}

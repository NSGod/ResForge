//
//  NFNT.swift
//  BitmapFontEditor
//
//  Created by Mark Douma on 1/13/2026.
//

import Cocoa
import RFSupport
import CoreFont

extension NFNT {
    
    struct Glyph {
        let charCode:       CharCode16
        let uv:             UVBMP
        let glyphRect:      NSRect
        let offset:         Int8
        let width:          Int8

        var pixelOffset:    Int16 {
            return Int16(glyphRect.origin.x)
        }

        /// `.notdef` ? NO
        var isMissing: Bool {
            self.offset == -1 && self.width == -1 && self.glyphRect == .zero
        }

        weak var nfnt:      NFNT!

        static let nullGlyph: Glyph = .init(glyphRect: .zero, offset: -1, width: -1, charCode: CharCode16.max, uv: .undefined, nfnt:nil)

        init(glyphRect: NSRect, offset: Int8, width: Int8, charCode: CharCode16, uv: UVBMP, nfnt: NFNT?) {
            self.offset = offset
            self.width = width
            if self.offset == -1 && self.width == -1 {
                self.glyphRect = .zero
            } else {
                self.glyphRect = glyphRect
            }
            self.charCode = charCode
            self.uv = uv
            self.nfnt = nfnt
        }
    }

    public struct FontType: OptionSet {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }

        public static let hasImageHeightTable      = FontType(rawValue: 1 << 0)
        public static let hasGlyphWidthTable       = FontType(rawValue: 1 << 1)
        public static let font2BitDepth            = FontType(rawValue: 1 << 2)  // 4
        public static let font4BitDepth            = FontType(rawValue: 1 << 3)  // 8
        public static let font8BitDepth            = FontType(rawValue: 12)      // 12
        public static let hasFctbResource          = FontType(rawValue: 1 << 7)
        public static let isSyntheticFont          = FontType(rawValue: 1 << 8)
        public static let isColorFont              = FontType(rawValue: 1 << 9)
        // 10 - 11; reserved, should be 0
        public static let reserved12               = FontType(rawValue: 1 << 12) // reserved, should be 1
        public static let isFixedWidthFont         = FontType(rawValue: 1 << 13)
        public static let expandFontHeight         = FontType(rawValue: 1 << 14) // reserved, should be 0
        // 15 reserved, should be 0
    }
}

public final class NFNT: NSObject {
    struct FontRec {
        static let length = 26
    }

    public var fontType:            FontType    /// UInt16
    @objc dynamic var firstChar:    Int16       /// ASCII code of first character
    @objc dynamic var lastChar:     Int16       /// ASCII code of last character
    @objc dynamic var widMax:       Int16       /// maximum character width
    @objc dynamic var kernMax:      Int16       /// negative of maximum character kern
    @objc dynamic var nDescent:     Int16       /// neg of `descent`, or if >0, high word of `owTLoc`
    @objc dynamic var fRectWidth:   Int16       /// width of font rectangle
    @objc dynamic var fRectHeight:  Int16       /// height of font rectangle
    @objc dynamic var owTLoc:       UInt16      /// offset to offset/width table
    @objc dynamic var ascent:       Int16       /// ascent
    @objc dynamic var descent:      Int16       /// descent
    @objc dynamic var leading:      Int16       /// leading
    @objc dynamic var rowWords:     Int16       /// row width of bit image / 2
                                                /// `rowWords` × 16 = width of image in px.

    var lineHeight:             CGFloat { CGFloat(fRectHeight + leading) }

    lazy var glyphs:            [Glyph] = {
        do {
            try buildImageAndGlyphsIfNeeded()
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
        return _glyphs
    }()

    // FIXME: this should be CharCode16s to Glyphs, should it not?
    // actually, UVBMP or Character would make more sense than char codes
    lazy var glyphEntries:      [String: Glyph] = {
        do {
            try buildImageAndGlyphsIfNeeded()
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
        return _glyphEntries
    }()

    /// can be nil if `rowWords` == 0
    /// image's dimensions are `fRectHeight` px. x `rowWords x 16` px.
    lazy var bitmapImage:       NSImage? = {
        do {
            try buildImageAndGlyphsIfNeeded()
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
        return _bitmapImage
    }()

    /// can be nil if `rowWords` == 0
    lazy var bitmapImageData:        Data? = {
        do {
            try buildImageAndGlyphsIfNeeded()
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
        return _bitmapImageData
    }()

    private var pixelOffsets:               [Int16]!
    private var widths:                     [Int8]!
    private var offsets:                    [Int8]!

    private var glyphWidths:                [Fixed8Dot8]?
    private var imageHeights:               [Int16]?

    lazy var encoding:                      MacEncoding = {
        guard let manager else { return .macRoman }
        /// we want the 'FOND' resource that has a font association table entry that
        /// references our 'NFNT', and which has the lowest possible `fontStyle` value,
        /// since that 'FOND' will usually have the most accurate info. For example, let's say
        /// our 'NFNT' is for `Helvetica-Bold 24`. It will likely be referenced in 2 different
        /// 'FOND's:
        /// 1) The 'FOND' named plain `"Helvetica"` where the font association table has an
        /// entry for our 'NFNT' where the font style is `1` for bold. This refers to taking the
        /// plain style Helvetica and applying the Bold style mask to it to produce the bold variant.
        /// 2) The 'FOND' named `"Helvetica Bold"` where the font association table has an entry
        /// for our 'NFNT' where the style is `0`, or plain (meaning unadulterated from standard, which is bold).
        /// We prefer 2) over 1).
        let fondResources = manager.allResources(ofType: .fond, currentDocumentOnly: false)
        var targetFOND: FOND? = nil
        var fontStyle: MacFontStyle? = nil
        for fondResource in fondResources {
            do {
                let fond = try FOND(with: fondResource)
                for entry in fond.fontAssociationTable.entries {
                    if entry.fontID == resource.id {
                        if let currentTargetFOND = targetFOND, let currentFontStyle = fontStyle {
                            if entry.fontStyle < currentFontStyle {
                                targetFOND = fond
                                fontStyle = entry.fontStyle
                            }
                        } else {
                            targetFOND = fond
                            fontStyle = entry.fontStyle
                        }
                    }
                }
            } catch {
                NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
            }
        }
        return targetFOND?.encoding ?? .macRoman
    }()

    // MARK: -
    private var _glyphs:            [Glyph] = []
    private var _glyphEntries:      [String: Glyph] = [:]
    private var _bitmapImage:       NSImage?
    private var _bitmapImageData:   Data?

    private var resource:           Resource
    private var reader:             BinaryDataReader
    private var haveBuiltGlyphs:    Bool = false
    private var manager:            RFEditorManager?

    // MARK: - init
    init(with resource: Resource, manager: RFEditorManager? = nil) throws {
        reader = BinaryDataReader(resource.data)
        self.manager = manager
        self.resource = resource
        fontType = FontType(rawValue: try reader.read())
        firstChar = try reader.read()
        lastChar = try reader.read()
        widMax = try reader.read()
        kernMax = try reader.read()
        nDescent = try reader.read()
        fRectWidth = try reader.read()
        fRectHeight = try reader.read()
        owTLoc = try reader.read()
        ascent = try reader.read()
        descent = try reader.read()
        leading = try reader.read()
        rowWords = try reader.read()
    }

    public func data() throws -> Data {
        let handle = DataHandle()
        _ = glyphs; _ = glyphEntries; _ = bitmapImage
        /// update `owTLoc` here
        handle.write(fontType)
        handle.write(firstChar)
        handle.write(lastChar)
        handle.write(widMax)
        handle.write(kernMax)
        handle.write(nDescent)
        handle.write(fRectWidth)
        handle.write(fRectHeight)
        handle.write(owTLoc)
        handle.write(ascent)
        handle.write(descent)
        handle.write(leading)
        handle.write(rowWords)
        if let bitmapImageData {
            handle.writeData(bitmapImageData)
        }
        if let pixelOffsets {
            pixelOffsets.forEach { handle.write($0) }
        }
        if let widths, let offsets {
            zip(widths, offsets).forEach {
                if $0 == -1 && $1 == -1 {
                    handle.write(-1 as Int16)
                } else {
                    let widthOffset: Int16 = Int16($0) | (Int16($1) << 8)
                    handle.write(widthOffset)
                }
            }
        }
        if let glyphWidths {
            glyphWidths.forEach { handle.write($0) }
        }
        if let imageHeights {
            imageHeights.forEach { handle.write($0) }
        }
        return handle.data
    }

    private func buildImageAndGlyphsIfNeeded() throws {
        if haveBuiltGlyphs { return }
        var fontBitDepth: Int16 = 0
        if fontType.contains(.font8BitDepth) {
            fontBitDepth = 8
        } else if fontType.contains(.font4BitDepth) {
            fontBitDepth = 4
        } else if fontType.contains(.font2BitDepth) {
            fontBitDepth = 2
        } else {
            fontBitDepth = 1
        }
        try reader.pushPosition(Int(FontRec.length))
        defer { reader.popPosition() }
        if rowWords == 0 {
            /// this contains no bitmap data
            NSLog("\(type(of: self)).\(#function)() **** NOTICE: rowWords == 0 && this NFNT contains no bitmap data. Resource length: \(resource.data.count)")
            if reader.bytesRemaining > 0 {
                NSLog("\(type(of: self)).\(#function)() **** yet NFNT contains more data!")
            }
            haveBuiltGlyphs = true
            return
        }
        /// `Bit image table`. The bit image of the glyphs in the font. The glyph images of every
        /// defined glyph in the font are placed sequentially in order of increasing ASCII code.
        /// The bit image is one pixel image with no undefined stretches that has a height given
        /// by the value of the font rectangle element and a width given by the value of the bit
        /// image row width element. The image is padded at the end with extra pixels to make its
        /// length a multiple of 16.

        // avoid overflow
        let length: Int = Int(fRectHeight) * Int(rowWords * 16) * Int(fontBitDepth)/8
        bitmapImageData = try reader.readData(length: length)
        guard let bitmapImageData else {
            return
        }
        guard let bitmapImageRep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                                    pixelsWide: Int(rowWords * 16),
                                                    pixelsHigh: Int(fRectHeight),
                                                    bitsPerSample: Int(fontBitDepth),
                                                    samplesPerPixel: 1,
                                                    hasAlpha: false,
                                                    isPlanar: false,
                                                    colorSpaceName: NSColorSpaceName.calibratedWhite,
                                                    bytesPerRow: Int(rowWords) * 2,
                                                    bitsPerPixel: Int(fontBitDepth)) else {
            // FIXME: throw better error
            NSLog("\(type(of: self)).\(#function)() *** ERROR: bitmapImageRep == nil")
            throw CocoaError(.fileReadCorruptFile)
        }
        // FIXME: add better support for higher font bit depths? Though I've never encountered them in the wild...
        // Since black colorspaces are deprecated, we'll use white but need to flip the bits
        guard let bitmapData: UnsafeMutablePointer<UInt8> = bitmapImageRep.bitmapData else {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: bitmapImageRep.bitmapData == nil")
            // FIXME: throw proper error
            throw CocoaError(.fileReadCorruptFile)
        }
        for i in 0..<length {
            // NOTE: here, each byte represents 8 pixels worth of data, & we're flipping all 8 bits at the same time
            bitmapData[i] = ~bitmapImageData[bitmapImageData.startIndex + i]
        }
        /// We might as well make an RGBA image of this properly padded image so that the `vImageConvert_AnyToAny()`
        /// function will work properly. In more recent versions of OS X, trying to draw the B&W bitmap image for every
        /// letter was trying to convert each tiny image segment to RGBA on the fly, which could fail if `vImageConvert_AnyToAny()`
        /// (called behind the scenes) didn't like the dimensions given.
        /// Actually, rather than using bitmapImageRepByConvertingToImageSpace:, which could fail in previous versions
        /// of OS X, we'll do the conversion ourselves.
        let sRGBRef = CGColorSpace.init(name: CGColorSpace.sRGB)!
        let bitmapContext = CGContext(data: nil,
                                      width: Int(rowWords) * 16,
                                      height: Int(fRectHeight),
                                      bitsPerComponent: 8,
                                      bytesPerRow: Int(rowWords) * 16 * 4,
                                      space: sRGBRef,
                                      bitmapInfo: CGBitmapInfo(alpha: .noneSkipLast))
        guard let imageRef = bitmapImageRep.cgImage else {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: failed to get CGImage from bitmapImageRep == \(bitmapImageRep)")
            throw CocoaError(.fileReadCorruptFile)
        }
        bitmapContext?.draw(imageRef, in: CGRectMake(0.0, 0.0, CGFloat(rowWords * 16), CGFloat(fRectHeight)))
        guard let rgbImageRef = bitmapContext?.makeImage() else {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: failed to make image from bitmapContext == \(String(describing: bitmapContext))")
            throw CocoaError(.fileReadCorruptFile)
        }
        let rgbImageRep = NSBitmapImageRep(cgImage: rgbImageRef)
        let image = NSImage(size: rgbImageRep.size)
        image.addRepresentation(rgbImageRep)
        _bitmapImage = image

        /// `Bitmap location table`. For every glyph in the font, this table contains a word that
        /// speciﬁes the bit offset to the location of the bitmap for that glyph in the bit image table.
        /// If a glyph is missing from the font, its entry contains the same value for its location as
        /// the entry for the next glyph. The missing glyph is the last glyph of the bit image for
        /// that font. The last word of the table contains the offset to one bit beyond the end of the
        /// bit image. You can determine the image width of each glyph from the bitmap location
        /// table by subtracting the bit offset to that glyph from the bit offset to the next glyph in
        /// the table.

        // FIXME: !! we should probably update this to use MacEncoding.
        //        pixelOffsets = try (firstChar...lastChar).map { _ in try reader.read() }
        //        pixelOffsets = try (Int(firstChar)...Int(lastChar) + 1).map { _ in try reader.read() }
        pixelOffsets = try (Int(firstChar)...Int(lastChar) + 2).map { _ in try reader.read() }
        widths = []
        offsets = []

        /// `Offset to width/offset table`. An integer value that specifies the offset to the
        /// offset/ width table from this point in the font record, `*in words*`. If this font has
        /// very large tables, this value is only the low word of the offset, and the
        /// negated descent value is the high word, as explained in the following section:
        /// The offset to the width/offset table element of the bitmapped font resource is
        /// represented as the `owtLoc` field in the FontRec data type. This field defines
        /// the offset from the beginning of the resource to the beginning of the
        /// width/offset table. The value of `nDescent`, when positive, is used as the high-order 16 bits
        /// in the 32-bit value that is used to store the offset of the width table from the beginning of
        /// the resource. To compute the actual offset, the Font Manager uses this computation:

        /// `actualOffsetWord := BSHL(nDescent, 16) + owTLoc;`

        /// NOTE: here, (8 x MemoryLayout<Int16>.size) is the partial size of the first 8 elements of the FontRec (`fontType` thru `fRectHeight`)
        /// Multiply by 2 because it's in words and we want bytes.
        let widthTableOffset: UInt32 = (UInt32(nDescent > 0 ? nDescent << 16 : 0) + UInt32(owTLoc)) * 2
        try reader.pushPosition(Int(8 * MemoryLayout<Int16>.size) + Int(widthTableOffset))
        defer { reader.popPosition() }

        /// `Width/offset table`. For every glyph in the font, this table contains a word with
        /// the glyph offset in the high-order byte and the glyph’s width, in integer form, in the
        /// low-order byte. The value of the offset, when added to the maximum kerning
        /// value for the font, determines the horizontal distance from the glyph origin to the left
        /// edge of the bit image of the glyph, in pixels. If this sum is negative, the glyph origin
        /// is to the right of the glyph image’s left edge, meaning the glyph kerns to the left.
        /// If the sum is positive, the origin is to the left of the image’s left edge. If the sum equals
        /// zero, the glyph origin corresponds with the left edge of the bit image. Missing glyphs
        /// are represented by a word value of –1. The last word of this table is also –1,
        /// representing the end.
        //        for _ in firstChar..<lastChar {
        //        for _ in firstChar...lastChar {
        for _ in Int(firstChar)...Int(lastChar) + 2 {
            let widthOffset: Int16 = try reader.read()
            if widthOffset == -1 {
                widths.append(-1)
                offsets.append(-1)
            } else {
                let widthEntry: Int8 = Int8(widthOffset & 0x00ff)   // low-order byte
                let offsetEntry: Int8 = Int8(widthOffset >> 8)      // high-order byte
                widths.append(widthEntry)
                offsets.append(offsetEntry)
            }
        }

        // FIXME: this needs work, I think
        for i in Int(firstChar)...Int(lastChar) + 2 {
            let charCode = CharCode16(i - Int(firstChar))
            let uv: UVBMP
            if charCode > CharCode.max {
                uv = .undefined
            } else {
                uv = encoding.uv(for: CharCode(charCode))
            }
            let asciiEntryKey: String
            if uv != .undefined, let scalar = UnicodeScalar(uv) {
                asciiEntryKey = String(scalar)
            } else {
                asciiEntryKey = "\(i)"
            }
            if i >= Int(firstChar)  && i < Int(lastChar) + 2 {
                let pixelOffsetEntry = pixelOffsets[i - Int(firstChar)]
                let pixelOffsetEntryPlusOne = pixelOffsets[i - Int(firstChar) + 1]
                let offsetEntry = offsets[i - Int(firstChar)]
                let widthEntry = widths[i - Int(firstChar)]
                let glyphRect = NSMakeRect(CGFloat(pixelOffsetEntry), 0.0, CGFloat(pixelOffsetEntryPlusOne - pixelOffsetEntry), CGFloat(fRectHeight))
                let entry = Glyph(glyphRect: glyphRect, offset: offsetEntry, width: widthEntry, charCode: charCode, uv: uv, nfnt: self)
                _glyphEntries[asciiEntryKey] = entry
                _glyphs.append(entry)
            } else if i >= lastChar {
                // FIXME: !! figure this out, I'm not really sure what I was thinking
                _glyphEntries[asciiEntryKey] = Glyph.nullGlyph
                _glyphs.append(Glyph.nullGlyph)
            }
        }
        haveBuiltGlyphs = true
        /// never encountered these, but worth a shot
        if reader.bytesRemaining > 0 {
            glyphWidths = try (Int(firstChar)...Int(lastChar) + 2).map { _ in try reader.read() }
        }
        if fontType.contains(.hasImageHeightTable) {
            imageHeights = try (Int(firstChar)...Int(lastChar) + 2).map { _ in try reader.read() }
        }
    }

    public static let notDef = ".notdef"
}

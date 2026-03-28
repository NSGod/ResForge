//
//  NFNT.swift
//  CoreFont
//
//  Created by Mark Douma on 1/13/2026.
//

import Cocoa
import RFSupport

extension NFNT {

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
        public static let expandFontHeight         = FontType(rawValue: 1 << 14)
        // 15 reserved, should be 0
    }
}

public final class NFNT: NSObject {
    struct FontRec {
        static let length = 26
    }

    public var fontType:                    FontType    /// UInt16
    @objc dynamic public var firstChar:     Int16       /// ASCII code of first character
    @objc dynamic public var lastChar:      Int16       /// ASCII code of last character
    @objc dynamic public var widMax:        Int16       /// maximum character width
    @objc dynamic public var kernMax:       Int16       /// negative of maximum character kern
    @objc dynamic public var nDescent:      Int16       /// neg of `descent`, or if >0, high word of `owTLoc`
    @objc dynamic public var fRectWidth:    Int16       /// width of font rectangle
    @objc dynamic public var fRectHeight:   Int16       /// height of font rectangle
    @objc dynamic public var owTLoc:        UInt16      /// offset to offset/width table
    @objc dynamic public var ascent:        Int16       /// ascent
    @objc dynamic public var descent:       Int16       /// descent
    @objc dynamic public var leading:       Int16       /// leading
    @objc dynamic public var rowWords:      Int16       /// row width of bit image / 2
                                                        /// `rowWords` × 16 = width of image in px.

    public var lineHeight:             CGFloat { CGFloat(fRectHeight + leading) }

    @objc dynamic public lazy var glyphs:            [Glyph] = {
        do {
            try buildImageAndGlyphsIfNeeded()
        } catch {
            NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
        }
        return _glyphs
    }()

    /// can be nil if `rowWords` == 0
    /// image's dimensions are `fRectHeight` px. x `rowWords x 16` px.
    public lazy var bitmapImage:       NSImage? = {
        do {
            try buildImageAndGlyphsIfNeeded()
        } catch {
            NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
        }
        return _bitmapImage
    }()

    /// can be nil if `rowWords` == 0
    public lazy var bitmapImageData:   Data? = {
        do {
            try buildImageAndGlyphsIfNeeded()
        } catch {
            NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
        }
        return _bitmapImageData
    }()

    /// if `rowWords` == 0, will be `.nullGlyph`
    public lazy var notDef:            Glyph = {
        do {
            try buildImageAndGlyphsIfNeeded()
        } catch {
            NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
        }
        return _notDef
    }()

    lazy private var charsToGlyphs:         [Character: Glyph] = {
        do {
            try buildImageAndGlyphsIfNeeded()
        } catch {
            NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
        }
        return _charsToGlyphs
    }()

    private var pixelOffsets:               [Int16]!
    private var widths:                     [Int8]!
    private var offsets:                    [Int8]!

    private var glyphWidths:                [Fixed8Dot8]?
    private var imageHeights:               [Int16]?

    /// means there is no `FOND` resource which claims us:
    public lazy var isOrphaned:             Bool = {
        _ = encoding
        return _isOrphaned
    }()

    public lazy var encoding:               MacEncoding = {
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
                        _isOrphaned = false
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
    private var _bitmapImage:       NSImage?
    private var _bitmapImageData:   Data?
    private var _notDef:            Glyph!
    private var _charsToGlyphs:     [Character: Glyph]!
    private var _isOrphaned:        Bool = true
    private var resource:           Resource
    private var reader:             BinaryDataReader
    private var haveBuiltGlyphs:    Bool = false
    private var manager:            RFEditorManager?

    // MARK: - init
    public init(with resource: Resource, manager: RFEditorManager? = nil) throws {
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
        _ = glyphs; _ = charsToGlyphs; _ = bitmapImage
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

    public func glyph(for character: Character) -> Glyph {
        return charsToGlyphs[character] ?? notDef
    }

    private func buildImageAndGlyphsIfNeeded() throws {
        if haveBuiltGlyphs { return }
        if rowWords == 0 {
            /// This `NFNT` contains no bitmap data.
            /// This is often the case with Asian two-byte-encoding fonts, where, rather
            /// than having an incomplete set of bitmaps in the `NFNT`, they have an empty `NFNT`
            /// with the bitmaps in the `sfnt`s `bdat` table.
            NSLog("\(type(of: self)).\(#function) **** NOTICE: rowWords == 0 && this NFNT contains no bitmap data. Resource length: \(resource.data.count)")
            if reader.bytesRemaining > 0 {
                NSLog("\(type(of: self)).\(#function) **** yet NFNT contains more data!")
            }
            _charsToGlyphs = [:]
            _notDef = .nullGlyph
            haveBuiltGlyphs = true
            return
        }
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
                                                    colorSpaceName: .calibratedWhite,
                                                    bytesPerRow: Int(rowWords) * 2,
                                                    bitsPerPixel: Int(fontBitDepth)) else {
            // FIXME: throw better error
            NSLog("\(type(of: self)).\(#function) *** ERROR: bitmapImageRep == nil")
            throw CocoaError(.fileReadCorruptFile)
        }
        // FIXME: add better support for higher font bit depths? Though I've never encountered them in the wild...
        // Since black colorspaces are deprecated, we'll use white but need to flip the bits
        let bitmapData = bitmapImageRep.bitmapData!
        bitmapImageData.copyBytes(to: bitmapData, count: length)
        for i in 0..<length {
            // NOTE: here, each byte represents 8 pixels worth of data, & we're flipping all 8 bits at the same time
            bitmapData[i] ^= 0xFF
        }
        /// We might as well make an RGBX image of this properly padded image so that the `vImageConvert_AnyToAny()`
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
            NSLog("\(type(of: self)).\(#function) *** ERROR: failed to get CGImage from bitmapImageRep == \(bitmapImageRep)")
            throw CocoaError(.fileReadCorruptFile)
        }
        bitmapContext?.draw(imageRef, in: CGRectMake(0.0, 0.0, CGFloat(rowWords * 16), CGFloat(fRectHeight)))
        guard let rgbImageRef = bitmapContext?.makeImage() else {
            NSLog("\(type(of: self)).\(#function) *** ERROR: failed to make image from bitmapContext == \(String(describing: bitmapContext))")
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

        /// So additional info on where this 258 character count comes from: I first saw code
        /// that alluded to this in FontForge:
        /// https://github.com/fontforge/fontforge/blob/7195402701ace7783753ef9424153eff48c9af44/fontforge/macbinary.c#L2342
        /// The documentation in Inside Macintosh: Text, regarding this stuff is, at least IMO, not the
        /// clearest. When viewing an `NFNT` in Resorcerer that has a standard 0...255 range,
        /// it also shows 258 entries, indexed 0...257. First, there's the standard 255. Following that, there's
        /// the missing glyph entry, which is usually a rectangular box — w/ or w/o an X through it —
        /// to be used for any char codes that don't have an actual bitmap glyph image. Following that is
        /// a sentinel final glyph entry that has a -1 offset and width.
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
        for i in Int(firstChar)...Int(lastChar) + 2 {
            let widthOffset: Int16 = try reader.read()
            if widthOffset == -1 {
                widths.append(-1)
                offsets.append(-1)
            } else {
                if i == Int(lastChar) + 2 {
                    /// Force the last width and offset entries to be -1 regardless
                    /// of what's present in the existing file. I've seen Fontographer
                    /// have junk values like -1232, which is -5, 48, and which would crash the code below.
                    /// Or perhaps I'm going too far and should only be lastChar + 1?
                    NSLog("\(type(of: self)).\(#function) last width/offset: \(widthOffset)")
                    let width: Int16 = widthOffset & 0x00ff
                    let offset: Int16 = widthOffset >> 8
                    NSLog("\(type(of: self)).\(#function) last width: \(width), offset: \(offset)")
                    widths.append(-1)
                    offsets.append(-1)
                } else {
                    let width: Int8 = Int8(bitPattern: UInt8(widthOffset & 0x00ff))   // low-order byte
                    let offset: Int8 = Int8(bitPattern: UInt8(widthOffset >> 8))      // high-order byte
                    widths.append(width)
                    offsets.append(offset)
                }
            }
        }
        _charsToGlyphs = [:]
        for i in Int(firstChar)...Int(lastChar) + 2 {
            let charCode = CharCode16(i - Int(firstChar))
            var uv: UVBMP
            if charCode > CharCode.max {
                uv = .undefined
            } else {
                uv = encoding.uv(for: CharCode(charCode))
            }
            var char: Character? = nil
            if uv != .undefined, let scalar = UnicodeScalar(uv) {
                char = Character(scalar)
            }
            if i >= Int(firstChar)  && i < Int(lastChar) + 2 {
                let pixelOffsetEntry = pixelOffsets[i - Int(firstChar)]
                let pixelOffsetEntryPlusOne = pixelOffsets[i - Int(firstChar) + 1]
                let offset = offsets[i - Int(firstChar)]
                let width = widths[i - Int(firstChar)]
                let glyphRect: NSRect
                if offset == -1, width == -1 {
                    glyphRect = .zero
                    /// if low ASCII glyphs are missing, this probably isn't the extended .macRoman encoding
                    uv = .undefined
                } else {
                    glyphRect = NSMakeRect(CGFloat(pixelOffsetEntry), 0.0, CGFloat(pixelOffsetEntryPlusOne - pixelOffsetEntry), CGFloat(fRectHeight))
                }
                let glyph = Glyph(glyphRect: glyphRect, offset: offset, width: width, charCode: charCode, uv: uv, nfnt: self)
                if let char {
                    _charsToGlyphs[char] = glyph
                }
                _glyphs.append(glyph)
                if i == Int(lastChar) + 1 {
                    _notDef = glyph
                }
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
}

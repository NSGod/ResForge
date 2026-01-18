//
//  NFNT.swift
//  BitmapFontEditor
//
//  Created by Mark Douma on 1/13/2026.
//

import Cocoa
import RFSupport
import CoreFont

public class NFNT: NSObject {
    struct FontRec {
        static let length = 26
    }

    var fontType:               FontType        // UInt16
    @objc var firstChar:        Int16           // ASCII code of first character
    @objc var lastChar:         Int16           // ASCII code of last character
    @objc var widMax:           Int16           // maximum character width
    @objc var kernMax:          Int16           // negative of maximum character kern
    @objc var nDescent:         Int16           // negative of descent
    @objc var fRectWidth:       Int16           // width of font rectangle
    @objc var fRectHeight:      Int16           // height of font rectangle
    @objc var owTLoc:           UInt16          // offset to offset/width table
    @objc var ascent:           Int16           // ascent
    @objc var descent:          Int16           // descent
    @objc var leading:          Int16           // leading
    @objc var rowWords:         Int16           // row width of bit image / 2

    @objc var objcFontType:     FontType.RawValue {
        didSet { fontType = FontType(rawValue: objcFontType) }
    }

    var lineHeight:             CGFloat { CGFloat(fRectHeight + leading) }

    lazy var glyphs:            [Glyph] = {
        do {
            try buildImageAndGlyphsIfNeeded()
            return _glyphs
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
        return _glyphs
    }()

    lazy var glyphEntries:      [String: Glyph] = {
        do {
            try buildImageAndGlyphsIfNeeded()
            return _glyphEntries
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
        return _glyphEntries
    }()

    lazy var bitmapImage:       NSImage? = {
        do {
            try buildImageAndGlyphsIfNeeded()
            return _bitmapImage
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
        return _bitmapImage
    }()

    // FIXME: figure out something better for this?
    private var _glyphs:                [Glyph] = []
    private var _glyphEntries:          [String: Glyph] = [:]
    private var _bitmapImage:           NSImage?

    struct FontType: OptionSet {
        let rawValue: UInt16
        init(rawValue: UInt16) { self.rawValue = rawValue }

        static let hasImageHeightTable      = FontType(rawValue: 1 << 0)
        static let hasGlyphWidthTable       = FontType(rawValue: 1 << 1)
        static let font2BitDepth            = FontType(rawValue: 1 << 2)
        static let font4BitDepth            = FontType(rawValue: 1 << 3)
        static let font8BitDepth            = FontType(rawValue: 12)
        static let hasFctbResource          = FontType(rawValue: 1 << 7)
        static let isSyntheticFont          = FontType(rawValue: 1 << 8)
        static let isColorFont              = FontType(rawValue: 1 << 9)
        static let reserved12               = FontType(rawValue: 1 << 12)   // reserved, should be 1
        static let isFixedWidthFont         = FontType(rawValue: 1 << 13)
        static let expandFontHeight         = FontType(rawValue: 1 << 14)

        static func viewTag(forFontBitDepth: FontType) -> Int {
            switch forFontBitDepth {
                case .font8BitDepth:      return 3
                case .font4BitDepth:      return 2
                case .font2BitDepth:      return 1
                default:                  return 0
            }
        }
    }

    struct Glyph {
        let charCode:       CharCode16
        let glyphRect:      NSRect
        let offset:         Int8
        let width:          Int8

        var pixelOffset:    Int16 {
            return Int16(glyphRect.origin.x)
        }

        var isMissingGlyph: Bool {
            self.offset == -1 && self.width == -1 && self.glyphRect == .zero
        }

        weak var nfnt:      NFNT!

        static let nullGlyph: Glyph = .init(with: .zero, offset: -1, width: -1, charCode: CharCode16.max, nfnt:nil)

        init(with glyphRect: NSRect, offset: Int8, width: Int8, charCode: CharCode16, nfnt: NFNT?) {
            self.offset = offset
            self.width = width
            if self.offset == -1 && self.width == -1 {
                self.glyphRect = .zero
            } else {
                self.glyphRect = glyphRect
            }
            self.charCode = charCode
            self.nfnt = nfnt
        }
    }

    unowned var resource:       Resource
    private var reader:         BinaryDataReader

    private var haveBuiltGlyphs: Bool = false

    // MARK: - init
    convenience init(_ data: Data, resource: Resource) throws {
        let reader = BinaryDataReader(data)
        try self.init(reader, resource: resource)
    }

    init(_ binReader: BinaryDataReader, resource: Resource) throws {
        self.reader = binReader
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
        objcFontType = fontType.rawValue
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
            // this contains no bitmap data
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
        let bitmapImageData: Data = try reader.readData(length: length)
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
            // FIXME: throw real error
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

        /// `Bitmap location table`. For every glyph in the font, this table contains a word that
        /// speciﬁes the bit offset to the location of the bitmap for that glyph in the bit image table.
        /// If a glyph is missing from the font, its entry contains the same value for its location as
        /// the entry for the next glyph. The missing glyph is the last glyph of the bit image for
        /// that font. The last word of the table contains the offset to one bit beyond the end of the
        /// bit image. You can determine the image width of each glyph from the bitmap location
        /// table by subtracting the bit offset to that glyph from the bit offset to the next glyph in
        /// the table.

        // FIXME: !! we should probably update this to use MacEncoding.
        var pixelOffsets:   [Int16] = []
        var widthEntries:   [Int8] = []
        var offsetEntries:  [Int8] = []

        for _ in firstChar...lastChar {
            let pixelOffset: Int16 = try reader.read()
            pixelOffsets.append(pixelOffset)
        }

        /// `Offset to width/offset table`. An integer value that specifies the offset to the
        /// offset/ width table from this point in the font record, in words. If this font has
        /// very large tables, this value is only the low word of the offset, and the
        /// negated descent value is the high word, as explained in the following section:
        /// The offset to the width/offset table element of the bitmapped font resource is
        /// represented as the `owtLoc` field in the FontRec data type. This field defines
        /// the offset from the beginning of the resource to the beginning of the
        /// width/offset table. The value of nDescent, when positive, is used as the high-order 16 bits
        /// in the 32-bit value that is used to store the offset of the width table from the beginning of
        /// the resource. To compute the actual offset, the Font Manager uses this computation:

        /// `actualOffsetWord := BSHL(nDescent, 16) + owTLoc;`

        // NOTE: here, (8 * MemoryLayout<Int16>.size) is the partial size of the first 8 elements of the FFFontRecord (fontType thru fRectHeight)
        let widthTableOffset: UInt32 = UInt32(nDescent > 0 ? nDescent << 16 : 0) + UInt32(owTLoc)
        try reader.pushPosition(Int(8 * MemoryLayout<Int16>.size) + Int(widthTableOffset) * MemoryLayout<Int16>.size)
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
        for _ in firstChar..<lastChar {
            let widthOffset: Int16 = try reader.read()
            if widthOffset == -1 {
                widthEntries.append(-1)
                offsetEntries.append(-1)
            } else {
                let offsetEntry: Int8 = Int8(widthOffset >> 8)      // high-order byte
                let widthEntry: Int8 = Int8(widthOffset & 0x00ff)   // low-order byte
                offsetEntries.append(offsetEntry)
                widthEntries.append(widthEntry)
            }
        }

        // FIXME: this needs work, I think
        for i in Int(firstChar)...Int(lastChar) {
            let asciiEntryKey = ascii[i]
            if i >= firstChar && i < lastChar {
                let pixelOffsetEntry = pixelOffsets[i - Int(firstChar)]
                let pixelOffsetEntryPlusOne = pixelOffsets[i - Int(firstChar) + 1]
                let offsetEntry = offsetEntries[i - Int(firstChar)]
                let widthEntry = widthEntries[i - Int(firstChar)]
                let glyphRect = NSMakeRect(CGFloat(pixelOffsetEntry), 0.0, CGFloat(pixelOffsetEntryPlusOne - pixelOffsetEntry), CGFloat(fRectHeight))
                let entry = Glyph(with: glyphRect, offset: offsetEntry, width: widthEntry, charCode: CharCode16(i - Int(firstChar)), nfnt: self)
                _glyphEntries[asciiEntryKey] = entry
                _glyphs.append(entry)
            } else if i >= lastChar {
                // FIXME: figure this out, I'm not really sure what I was thinking
                _glyphEntries[asciiEntryKey] = Glyph.nullGlyph
                _glyphs.append(Glyph.nullGlyph)
            }
        }
        haveBuiltGlyphs = true
        _bitmapImage = image
    }

}

fileprivate let ascii: [String] = [
    "0x00",
    "0x01",
    "0x02",
    "0x03",
    "0x04",
    "0x05",
    "0x06",
    "0x07",
    "0x08",
    "0x09",
    "LF",
    "0x0b",
    "0x0c",
    "CR",
    "0x0e",
    "0x0f",
    "0x10",
    "0x11",
    "0x12",
    "0x13",
    "0x14",
    "0x15",
    "0x16",
    "0x17",
    "0x18",
    "0x19",
    "0x1a",
    "0x1b",
    "0x1c",
    "0x1d",
    "0x1e",
    "0x1f",
    " ",
    "!",
    "\"",
    "#",
    "$",
    "%",
    "&",
    "'",
    "(",
    ")",
    "*",
    "+",
    ",",
    "-",
    ".",
    "/",
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    ":",
    ";",
    "<",
    "=",
    ">",
    "?",
    "@",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z",
    "[",
    "\\",
    "]",
    "^",
    "_",
    "`",
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z",
    "{",
    "|",
    "}",
    "~",
    "DEL",
    "Ä",
    "Å",
    "Ç",
    "É",
    "Ñ",
    "Ö",
    "Ü",
    "á",
    "à",
    "â",
    "ä",
    "ã",
    "å",
    "ç",
    "é",
    "è",
    "ê",
    "ë",
    "í",
    "ì",
    "î",
    "ï",
    "ñ",
    "ó",
    "ò",
    "ô",
    "ö",
    "õ",
    "ú",
    "ù",
    "û",
    "ü",
    "†",
    "°",
    "¢",
    "£",
    "§",
    "•",
    "¶",
    "ß",
    "®",
    "©",
    "™",
    "´",
    "¨",
    "≠",
    "Æ",
    "Ø",
    "∞",
    "±",
    "≤",
    "≥",
    "¥",
    "µ",
    "∂",
    "∑",
    "∏",
    "π",
    "∫",
    "ª",
    "º",
    "Ω",
    "æ",
    "ø",
    "¿",
    "¡",
    "¬",
    "√",
    "ƒ",
    "≈",
    "∆",
    "«",
    "»",
    "…",
    "NBSP",
    "À",
    "Ã",
    "Õ",
    "Œ",
    "œ",
    "–",
    "—",
    "“",
    "”",
    "‘",
    "’",
    "÷",
    "◊",
    "ÿ",
    "Ÿ",
    "⁄",
    "€",
    "‹",
    "›",
    "ﬁ",
    "ﬂ",
    "‡",
    "·",
    "‚",
    "„",
    "‰",
    "Â",
    "Ê",
    "Á",
    "Ë",
    "È",
    "Í",
    "Î",
    "Ï",
    "Ì",
    "Ó",
    "Ô",
    "",
    "Ò",
    "Ú",
    "Û",
    "Ù",
    "ı",
    "ˆ",
    "˜",
    "¯",
    "˘",
    "˙",
    "˚",
    "¸",
    "˝",
    "˛",
    "ˇ",
]

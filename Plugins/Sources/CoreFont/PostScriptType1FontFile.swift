//
//  PostScriptType1FontFile.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Cocoa
import RFSupport
import Dispatch

public enum PostScriptError : LocalizedError {
    case invalidFontData(String?)
    case activationFailed(String?)
    case deactivationFailed(String?)
    case unsupportedFormat(String?)
}

// .pfa
public let MDUTTypePFAOutlineFont: String   = "com.adobe.postscript-pfa-font"
public let MDPFAOutlineFontType: String     = "PostScript Type 1 (ASCII) outline font"

// .pfb
public let MDUTTypePFBOutlineFont: String   = "com.adobe.postscript-pfb-font"
public let MDPFBOutlineFontType: String     = "PostScript Type 1 (Binary) outline font"

public class PSFontMetrics : NSObject, FontMetrics {
    public let unitsPerEm:                  UnitsPerEm
    @objc public let ascender:              CGFloat
    @objc public let descender:             CGFloat
    @objc public let leading:               CGFloat
    @objc public let underlinePosition:     CGFloat
    @objc public let underlineThickness:    CGFloat
    @objc public let italicAngle:           CGFloat
    @objc public let capHeight:             CGFloat
    @objc public let xHeight:               CGFloat
    @objc public let isFixedPitch:          Bool

    @objc public var objcUnitsPerEm: UInt16 {
        return unitsPerEm.rawValue
    }

    public init(font: NSFont) {
        unitsPerEm = UnitsPerEm(rawValue: UInt16(CTFontGetUnitsPerEm(font as CTFont)))
        let factor = CGFloat(unitsPerEm.rawValue) / font.pointSize
        ascender = font.ascender * factor
        descender = font.descender * factor
        leading = font.leading * factor
        underlinePosition = font.underlinePosition * factor
        underlineThickness = font.underlineThickness * factor
        italicAngle = font.italicAngle * factor // ??
        capHeight = font.capHeight * factor
        xHeight = font.xHeight * factor
        isFixedPitch = font.isFixedPitch
        super.init()
    }
}

// represents a PFA/PFB file
public final class PostScriptType1FontFile: NSObject {
    public var data:            Data          // stored in PFA format
    var fileUrl:                URL?

    public enum Format {
        case ascii      /// read/write supported
        case binary     /// - Important: Binary read is supported; write is not currently supported
    }

    @objc public let fullName:          String      // Frutiger 55 Roman    /FullName
    @objc public let familyName:        String      // Frutiger             /FamilyName
    @objc public let postScriptName:    String      // Frutiger-Roman       /FontName
    @objc public let displayName:       String

    @objc public let subFamilyName:     String?
    @objc public let uniqueName:        String?
    @objc public let copyright:         String?
    @objc public let version:           String?

    @objc public let metrics:           PSFontMetrics
    public let encoding:                CFStringEncoding
    public let characterSet:            CharacterSet

    public private(set) var font:       NSFont?
    private var descriptor:             NSFontDescriptor!

    public var isActivated:             Bool {
        guard descriptor != nil else { return false }
        guard font != nil else { return false }
        return true
    }

    /// A set of options that control what additional information is parsed from a PostScript Type 1 font file.
    ///
    public struct ParseOptions: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) { self.rawValue = rawValue }

        /// Gets font and naming metadata (e.g., family name, style, PostScript name).
        public static let `default`:    ParseOptions = []

        /// Requests local process activation of the font such that the `font` `NSFont` can be used for screen drawing
        /// - Important: If you have activated the font, you must call `deactivate()` before this
        ///   PostScriptType1FontFile is deallocated.
        public static let activate: ParseOptions = Self(rawValue: 1 << 1)

        /// Convenience option that combines `.default` and `.activate`
        public static let full:    ParseOptions = [.default, .activate]
    }

    /// we can read in both .pfa and .pfb files (.pfb will be auto transformed to .pfa)
    public convenience init(contentsOf url: URL, options: ParseOptions = .`default`) throws {
        let data = try Data(contentsOf: url)
        try self.init(data: data, options: options)
        self.fileUrl = url
    }

    public init(data: Data, options: ParseOptions = .`default`) throws {
        /// The data given to us could be in either PFA (ascii) format, or
        /// PFB (binary) format, so make sure to transform it to PFA before continuing
        let data = try Self.postScriptDataByTransforming(data, toFormat: .ascii)
        self.data = data
        /// Normally, I would have to decrypt and parse the PFA/PFB file by including code from
        /// Adobe's Font Development Kit for OpenType fonts (afdko), but we have an easier way.
        /// Despite .pfa/.pfb being a PC-originating format, there's actually built-in support
        /// for that format in macOS. In recent versions of macOS, QuickLook will happily
        /// preview a .pfa while ignoring the Mac 'LWFN' next to it. In 10.15+, we can use
        /// `CTFontManagerRegisterFontDescriptors()` to activate fonts without first having to
        /// write the data to a file. We can activate it, extract useful information and then
        /// deactivate it, without having to resort to using Adobe's parsing code.
        /// AFAIK, it's not possible to activate an individual `LWFN` file without also activating
        /// the font suitcase file that references it through a`FOND`, which probably isn't the best idea,
        /// given that we're potentially modifying the font behind `fontd`'s back.
        guard let descriptor: NSFontDescriptor = CTFontManagerCreateFontDescriptorFromData(self.data as CFData) as NSFontDescriptor? else {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: no font descriptor")
            throw CocoaError(.fileReadCorruptFile)
        }
        self.descriptor = descriptor
        let done = DispatchSemaphore(value: 0)
        let naptime = DispatchTime.now() + .seconds(10)
        let type = "\(type(of: self))"
        var actErrors: CFArray?
        DispatchQueue.global().async {
            CTFontManagerRegisterFontDescriptors([descriptor] as CFArray, .process, true) { errors, descDone in
                if (errors as NSArray).count > 0 {
                    NSLog("\(type).\(#function)() errors == \(errors)")
                    actErrors = errors
                }
                if descDone {
                    done.signal()
                }
                return true
            }
        }
        if done.wait(timeout: naptime) == .timedOut {
            NSLog("\(type).\(#function)() *** ERROR: CTFontManagerRegisterFontDescriptors() timed out")
        }
        font = .init(descriptor: descriptor, size: 48)
        guard let font else {
            throw PostScriptError.activationFailed("Errors: \(actErrors.debugDescription)")
        }
        metrics = PSFontMetrics(font: font)
        fullName = CTFontCopyFullName(font as CTFont) as String
        familyName = CTFontCopyFamilyName(font as CTFont) as String
        postScriptName = CTFontCopyPostScriptName(font as CTFont) as String
        displayName = CTFontCopyDisplayName(font as CTFont) as String
        subFamilyName = CTFontCopyName(font as CTFont, kCTFontSubFamilyNameKey) as String?
        uniqueName = CTFontCopyName(font as CTFont, kCTFontUniqueNameKey) as String?
        copyright = CTFontCopyName(font as CTFont, kCTFontCopyrightNameKey) as String?
        version = CTFontCopyName(font as CTFont, kCTFontVersionNameKey) as String?

        encoding = CTFontGetStringEncoding(font as CTFont)
        characterSet = font.coveredCharacterSet
        super.init()
        if !options.contains(.activate) {
            // deactivate the font
            try deactivate()
        }
    }

    deinit {
        if isActivated {
            fatalError("\(type(of: self)).\(#function)() This font is currently activated (isActive == true); you must call deactivate() before allowing it to be deallocated!")
        }
    }

    public func write(to url: URL, format: Format = .ascii) throws {
        if format != .ascii {
            throw PostScriptError.unsupportedFormat("Writing to .pfb format is not currently supported")
        }
        return try data.write(to: url, options: .atomic)
    }

    public func activate() throws {
        if isActivated {
            throw PostScriptError.activationFailed("Font is already activated")
        }
        guard descriptor != nil else {
            throw PostScriptError.activationFailed("Font descriptor is nil")
        }
        let done = DispatchSemaphore(value: 0)
        let naptime = DispatchTime.now() + .seconds(10)
        let type = "\(type(of: self))"
        var actErrors: CFArray?
        DispatchQueue.global().async {
            CTFontManagerRegisterFontDescriptors([self.descriptor] as CFArray, .process, true) { errors, descDone in
                if (errors as NSArray).count > 0 {
                    NSLog("\(type).\(#function)() errors == \(errors)")
                    actErrors = errors
                }
                if descDone {
                    done.signal()
                }
                return true
            }
        }
        if done.wait(timeout: naptime) == .timedOut {
            NSLog("\(type).\(#function)() *** ERROR: CTFontManagerRegisterFontDescriptors() timed out")
        }
        font = .init(descriptor: descriptor, size: 48)
        guard font != nil else {
            throw PostScriptError.activationFailed("Errors: \(actErrors.debugDescription)")
        }
    }

    public func deactivate() throws {
        if !isActivated {
            throw PostScriptError.deactivationFailed("Font is not currently activated")
        }
        let done = DispatchSemaphore(value: 0)
        let naptime = DispatchTime.now() + .seconds(10)
        let type = "\(type(of: self))"
        DispatchQueue.global().async {
            CTFontManagerUnregisterFontDescriptors([self.descriptor] as CFArray, .process, ) { errors, descDone in
                if (errors as NSArray).count > 0 {
                    NSLog("\(#function)() errors == \(errors)")
                }
                if descDone {
                    done.signal()
                }
                return true
            }
        }
        if done.wait(timeout: naptime) == .timedOut {
            NSLog("\(type).\(#function)() *** ERROR: CTFontManagerUnregisterFontDescriptors() timed out")
        }
        self.font = nil
    }

    private enum DataType: UInt8 {
        case ascii          = 1
        case binary         = 2
        case done           = 3
        case binaryMarker   = 128
        // mine:
        case none           = 255
    }

    fileprivate static let hexDataLineLength: Int = 64

    // MARK: only ascii is supported as output format
    private static func postScriptDataByTransforming(_ data: Data, toFormat: Format = .ascii) throws -> Data {
        let reader = BinaryDataReader(data, bigEndian: false)
        var fmt: UInt8 = try reader.peek()
        if let format = DataType(rawValue: fmt), format == .binaryMarker {
            /// is PFB
            if toFormat == .binary { return data }
            /// to ASCII:
            var mString = ""
            var lastFormat: DataType = .none
            var hexColumn = 0
            while true {
                fmt = try reader.read()
                let blckType: UInt8 = try reader.read()
                guard DataType(rawValue: fmt) != nil else {
                    throw PostScriptError.invalidFontData("Unknown token found in PostScript font data: \(fmt)")
                }
                guard let blockType = DataType(rawValue: blckType) else {
                    throw PostScriptError.invalidFontData("Unknown token found in PostScript font data: \(blckType)")
                }
                if blockType == .done { break }

                let blockLength: UInt32 = try reader.read()
                NSLog("\(type(of: self)).\(#function) blockLength: \(blockLength)")
                let blockData: Data = try reader.readData(length: Int(blockLength))
                if blockType == .ascii {
                    guard var mBlockString = String(data: blockData, encoding: .ascii) else {
                        NSLog("\(type(of: self)).\(#function) *** ERROR: failed to create string with ASCII encoding! skipping....")
                        continue
                    }
                    mBlockString = mBlockString.replacingOccurrences(of: "\r\n", with: "\n")
                    mBlockString = mBlockString.replacingOccurrences(of: "\r", with: "\n")
                    // FIXME: resolve octal character excape sequences ('\251' -> '©')
                    if lastFormat == .binary { mBlockString += "\n" }
                    mString.append(mBlockString)
                    lastFormat = .ascii
                } else if blockType == .binary {
                    if lastFormat != .binary { hexColumn = 0 }
                    let length = blockData.count
                    for i in 0..<length {
                        if hexColumn >= Self.hexDataLineLength {
                            mString += "\n"
                            hexColumn = 0
                        }
                        mString += String(format: "%02x", blockData[blockData.startIndex + i])
                        hexColumn += 2
                    }
                    lastFormat = .binary
                }
            }
            return mString.data(using: .ascii) ?? Data()
        } else {
            /// is already PFA, return existing data
            if toFormat == .ascii { return data }
            throw PostScriptError.unsupportedFormat("Converting PostScript Type 1 PFA to a PFB font is not currently supported")
        }
    }
}

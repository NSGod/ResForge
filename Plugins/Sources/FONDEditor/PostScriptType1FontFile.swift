//
//  File.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/11/2026.
//

import Cocoa
import RFSupport
import CoreText
import Dispatch

// .pfa
//NSString * const MDUTTypePFAOutlineFont           = @"com.adobe.postscript-pfa-font";
//NSString * const MDPFAOutlineFontType             = @"PostScript Type 1 (ASCII) outline font";
//
// .pfb
//NSString * const MDUTTypePFBOutlineFont           = @"com.adobe.postscript-pfb-font";
//NSString * const MDPFBOutlineFontType             = @"PostScript Type 1 (Binary) outline font";

protocol FontMetrics {
    var unitsPerEm:         UnitsPerEm  { get }
    var ascender:           CGFloat     { get }
    var descender:          CGFloat     { get }
    var leading:            CGFloat     { get }

    var underlinePosition:  CGFloat     { get }
    var underlineThickness: CGFloat     { get }
    var italicAngle:        CGFloat     { get }
    var capHeight:          CGFloat     { get }
    var xHeight:            CGFloat     { get }
    var isFixedPitch:       Bool        { get }
}

struct PSFontMetrics : FontMetrics {
    let unitsPerEm:         UnitsPerEm
    let ascender:           CGFloat
    let descender:          CGFloat
    let leading:            CGFloat
    let underlinePosition:  CGFloat
    let underlineThickness: CGFloat
    let italicAngle:        CGFloat
    let capHeight:          CGFloat
    let xHeight:            CGFloat
    let isFixedPitch:       Bool

    init(font: NSFont) {
        ascender = font.ascender
        descender = font.descender
        leading = font.leading
        underlinePosition = font.underlinePosition
        underlineThickness = font.underlineThickness
        italicAngle = font.italicAngle
        capHeight = font.capHeight
        xHeight = font.xHeight
        isFixedPitch = font.isFixedPitch
        unitsPerEm = UnitsPerEm(rawValue: Int(CTFontGetUnitsPerEm(font as CTFont)))
    }
}


// represents a PFA/PFB file
struct PostScriptType1FontFile {
    let data:           Data          // stored in PFA format
    var fileUrl:        URL?

    enum Format {
        case ascii      /// supported
        case binary     /// - Note: not currently supported
    }

    let fullName:           String      // Frutiger 55 Roman    /FullName
    let familyName:         String      // Frutiger             /FamilyName
    let postScriptName:     String      // Frutiger-Roman       /FontName

    let metrics:            PSFontMetrics
    let encoding:           CFStringEncoding
    let characterSet:       CharacterSet

    /// A set of options that control what additional information is parsed from a PostScript Type 1 font file.
    ///
    /// Use these options to request optional, potentially expensive parsing work beyond the raw font data.
    /// By default, no extra parsing is performed (`.none`).
    ///
    /// - Note: Options marked as “not currently supported” are placeholders for future functionality.
    ///   Supplying them will not change behavior at this time.
    struct ParseOptions: OptionSet {
        /// The raw bitmask value backing the option set.
        ///
        /// Each distinct option corresponds to a unique bit in this value.
        let rawValue: Int
        /// Creates a new set of parsing options from a raw bitmask.
        ///
        /// - Parameter rawValue: The raw bitmask representing one or more options.
        init(rawValue: Int) { self.rawValue = rawValue }
        
        /// Performs no additional parsing beyond loading the font data.
        ///
        /// This is the default, fastest, and currently, the only supported behavior.
        static let none:    ParseOptions = []
        
        /// Requests parsing of font and naming metadata (e.g., family name, style, PostScript name).
        ///
        /// - Important: Not currently supported. Supplying this option has no effect yet.
        static let names:   ParseOptions = Self(rawValue: 1 << 0)   /// not currently supported
        
        /// Requests parsing of glyph-related data (e.g., glyph list, mappings).
        ///
        /// - Important: Not currently supported. Supplying this option has no effect yet.
        static let glyphs:  ParseOptions = Self(rawValue: 1 << 1)   /// not currently supported
        
        /// Convenience option that combines `.names` and `.glyphs` for comprehensive parsing.
        ///
        /// - Important: Not currently supported. Supplying this option has no effect yet.
        static let full:    ParseOptions = [.names, .glyphs]        /// not currently supported
    }

    init(contentsOf url: URL, options: ParseOptions = .none) throws {
        let data = try Data(contentsOf: url)
        try self.init(data: data)
        self.fileUrl = url
    }

    init(data: Data, options: ParseOptions = .none) throws {
        if !options.isEmpty {
            // FIXME: log error/warning
        }
        self.data = data
        /// Normally, I would have to decrypt and parse the PFA/PFB file by including code from
        /// Adobe's Font Development Kit for OpenType fonts (afdko), but we have an easier way.
        /// Despite .pfa/.pfb being a PC-originating format, there's actually built-in support
        /// for that format in macOS. QuickLook will happily preview a .pfa while ignoring
        /// the Mac 'LWFN' next to it in recent versions of macOS. In 10.15+, we can use
        /// `CTFontManagerRegisterFontDescriptors()` to activate fonts without first having to
        /// write the data to a file. We can activate it, extract useful information and then
        /// deactivate it, without having to resort to using Adobe's parsing code.
        /// AFAIK, it's not possible to activate an individual `LWFN` file without also activating
        /// the font suitcase file that references it through a`FOND`, which probably isn't the best idea,
        /// given that we're potentially modifying the font behind `fontd`'s back.
        if #available(macOS 10.15, *) {
            guard let descriptor: NSFontDescriptor = CTFontManagerCreateFontDescriptorFromData(self.data as CFData) as NSFontDescriptor? else {
                NSLog("\(type(of: self)).\(#function)() *** ERROR: no font descriptor")
                throw CocoaError(.fileReadCorruptFile)
            }
            var done = DispatchSemaphore(value: 0)
            var naptime = DispatchTime.now() + .seconds(10)
            let type = "\(type(of: self))"
            DispatchQueue.global().async {
                CTFontManagerRegisterFontDescriptors([descriptor] as CFArray, .process, true) { errors, descDone in
                    if (errors as NSArray).count > 0 {
                        NSLog("\(type).\(#function)() errors == \(errors)")
                    }
                    done.signal()
                    return true
                }
            }
            if done.wait(timeout: naptime) == .timedOut {
                NSLog("\(type).\(#function)() *** ERROR: CTFontManagerRegisterFontDescriptors() timed out")
            }
            let font: NSFont = .init(descriptor: descriptor, size: 12.0)!

            metrics = PSFontMetrics(font: font)
            fullName = CTFontCopyFullName(font as CTFont) as String
            familyName = CTFontCopyFamilyName(font as CTFont) as String
            postScriptName = CTFontCopyPostScriptName(font as CTFont) as String
            encoding = CTFontGetStringEncoding(font as CTFont)
            characterSet = font.coveredCharacterSet

            done = DispatchSemaphore(value: 0)
            naptime = DispatchTime.now() + .seconds(10)
            DispatchQueue.global().async {
                CTFontManagerUnregisterFontDescriptors([descriptor] as CFArray, .process, ) { errors, descDone in
                    if (errors as NSArray).count > 0 {
                        NSLog("\(type).\(#function)() errors == \(errors)")
                    }
                    done.signal()
                    return true
                }
            }
            if done.wait(timeout: naptime) == .timedOut {
                NSLog("\(type).\(#function)() *** ERROR: CTFontManagerUnregisterFontDescriptors() timed out")
            }
        } else {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: cannot call CTFontManagerRegisterFontDescriptors()")
            // FIXME: deal with this failure
            throw CocoaError(.featureUnsupported)
        }
    }
}

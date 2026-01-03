//
//  MacEncoding.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/1/2026.
//

import Foundation

struct MacEncoding {
    let name:                               String
    private(set) var isCustomEncoding:      Bool = false
    var logsInvalidCharCodes:               Bool = false

    private(set) lazy var glyphNameEntries: [GlyphNameEntry] = GlyphNameEntry.glyphNameEntries(with: self)

    init(name: String, encoding: [UVBMP]) {
        self.name = name
        self.encoding = encoding
    }

    // The numbers in the brackets are MacScriptIDs...
    static let macRoman                 = MacEncoding(name: "[0] Mac Roman", encoding: macRomanEncoding)
    static let macArabic                = MacEncoding(name: "[4] Mac Arabic", encoding: macArabicEncoding)
    static let macHebrew                = MacEncoding(name: "[5] Mac Hebrew", encoding: macHebrewEncoding)
    static let macGreek                 = MacEncoding(name: "[6] Mac Greek", encoding: macGreekEncoding)
    static let macCyrillic              = MacEncoding(name: "[7] Mac Cyrillic", encoding: macCyrillicEncoding)
    static let macCentralEuropean       = MacEncoding(name: "[29] Mac CE", encoding: macCEEncoding)
    static let macTurkish               = MacEncoding(name: "[0] Mac Turkish", encoding: macTurkishEncoding)
    static let macThai                  = MacEncoding(name: "[21] Mac Thai", encoding: macThaiEncoding)
    static let macCroatian              = MacEncoding(name: "[0] Mac Croatian", encoding: macCroatianEncoding)
    static let macIcelandic             = MacEncoding(name: "[0] Mac Icelandic", encoding: macIcelandicEncoding)
    static let macDevanagari            = MacEncoding(name: "[9] Mac Devanagari", encoding: macDevanagariEncoding)
    static let macRomanian              = MacEncoding(name: "[0] Mac Romanian", encoding: macRomanianEncoding)
    static let macFarsi                 = MacEncoding(name: "[4] Mac Farsi", encoding: macFarsiEncoding)
    static let macGujarati              = MacEncoding(name: "[11] Mac Gujarati", encoding: macGujaratiEncoding)
    static let macGurmukhi              = MacEncoding(name: "[10] Mac Gurmukhi", encoding: macGurmukhiEncoding)
    static let macZapfDingbats          = MacEncoding(name: "[0] Mac Zapf Dingbats", encoding: macZapfDingbatsEncoding)
    static let macSymbol                = MacEncoding(name: "[0] Mac Symbol", encoding: macSymbolEncoding)

    // primitive:
    func uv(for charCode: CharCode) -> UVBMP {
        return encoding[Int(charCode)]
    }

    func glyphName(for charCode: CharCode) -> String? {
        if let customGlyphName = customCharCodesToGlyphNames?[charCode] {
            return customGlyphName
        }
        let uv = uv(for: charCode)
        guard let glyphName = glyphName(for: uv) else {
            if logsInvalidCharCodes {
                NSLog("\(type(of: self)).\(#function)() INVALID charCode: \(charCode)")
            }
            return nil
        }
        return glyphName
    }

    func glyphName(for uv: UVBMP) -> String? {
        return AdobeGlyphList.glyphName(for: uv)
    }

    mutating func add(custom glyphNameEntries: [GlyphNameEntry]) {
        if customCharCodesToGlyphNames == nil { customCharCodesToGlyphNames = [:] }
        if var customEntries = customCharCodesToGlyphNames {
            for entry in glyphNameEntries {
                customEntries[entry.charCode] = entry.glyphName
            }
        }
        self.glyphNameEntries.append(contentsOf: glyphNameEntries)
        self.glyphNameEntries.sort(by: <)
        isCustomEncoding = true
    }

    static func macEncoding(for scriptID: MacScriptID, macLanguageID macLanguageIDPlus1: MacLanguageID = .none, postScriptFontName: String? = nil) -> MacEncoding? {
        var langID = macLanguageIDPlus1
        if (macLanguageIDPlus1 != .none && macLanguageIDPlus1 != .english) {
            // FIXME: is this safe?
            langID = MacLanguageID(rawValue: macLanguageIDPlus1.rawValue - 1)!
        }
        // TODO: this needs work
        if scriptID == .roman && langID == .turkish {
            return .macTurkish
        } else if scriptID == .roman && langID == .icelandic {
            return .macIcelandic
        } else if scriptID == .roman && langID == .romanian {
            return .macRomanian
        } else if scriptID == .roman && (langID == .croatian || langID == .slovenian) {
            return .macCroatian
        } else if scriptID == .roman, let psName = postScriptFontName, psName == symbolPSName {
            return .macSymbol
        } else if scriptID == .roman, let psName = postScriptFontName, psName.lowercased().hasPrefix(zapfDingbatsPSName2.lowercased()) {
            return .macZapfDingbats
        } else if scriptID == .arabic && langID == .farsi {
            return .macFarsi
        } else if scriptID == .arabic {
            return .macArabic
        } else if scriptID == .hebrew {
            return .macHebrew
        } else if scriptID == .greek {
            return .macGreek
        } else if scriptID == .cyrillic {
            return .macCyrillic
        } else if scriptID == .devanagari {
            return .macDevanagari
        } else if scriptID == .gujarati {
            return .macGujarati
        } else if scriptID == .gurmukhi {
            return .macGurmukhi
        } else if scriptID == .ceRoman {
            return .macCentralEuropean
        } else if scriptID == .thai {
            return .macThai
        }
        return .macRoman
    }

    private var customCharCodesToGlyphNames: [CharCode: String]?
    private let encoding: [UVBMP]

    fileprivate static let symbolPSName        = "Symbol"
    fileprivate static let zapfDingbatsPSName1 = "ZapfDingbatsITC"
    fileprivate static let zapfDingbatsPSName2 = "ZapfDingbats"
}

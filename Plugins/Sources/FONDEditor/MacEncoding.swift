//
//  MacEncoding.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/1/2026.
//

import Foundation

struct MacEncoding: CustomStringConvertible {
    let name:                               String
    private(set) var isCustomEncoding:      Bool = false
    var logsInvalidCharCodes:               Bool = false

    private(set) lazy var glyphNameEntries: [GlyphNameEntry] = GlyphNameEntry.glyphNameEntries(with: self)

    private(set) var coveredCharCodes:      IndexSet


    init(name: String, encoding: [UVBMP]) {
        self.name = name
        self.encoding = encoding
        var covCharCodes = IndexSet()
        for i in 0..<CharCode.max {
            let uv = encoding[Int(i)]
            if uv != .undefined {
                covCharCodes.insert(Int(i))
            }
        }
        coveredCharCodes = covCharCodes
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
    static let macDingbats              = MacEncoding(name: "[0] Mac Dingbats", encoding: macDingbatsEncoding)
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
                coveredCharCodes.insert(Int(entry.charCode))
            }
        }
        self.glyphNameEntries.append(contentsOf: glyphNameEntries)
        self.glyphNameEntries.sort(by: <)
        isCustomEncoding = true
    }

    static func encodingFor(scriptID: MacScriptID, languageID macLanguageIDPlus1: MacLanguageID = .none, postScriptFontName: String? = nil) -> MacEncoding {
        var langID = macLanguageIDPlus1
        if (macLanguageIDPlus1 != .none && macLanguageIDPlus1 != .english) {
            // FIXME: is this safe?
            langID = MacLanguageID(rawValue: macLanguageIDPlus1.rawValue - 1)!
        }
        // FIXME: this needs more work
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
        } else if scriptID == .roman, let psName = postScriptFontName, psName.lowercased().hasPrefix(dingbatsPSName2.lowercased()) {
            return .macDingbats
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

    /* From Appendix B, Table B-2 in Text.pdf */
    /* Script & FOND ID mapping:
     129      - 16383        Roman
     16384    - 16895        Japanese
     16896    - 17407        Traditional Chinese
     17408    - 17919        Korean
     17920    - 18431        Arabic
     18432    - 18943        Hebrew
     18944    - 19455        Greek
     19456    - 19967        Cyrillic
     19968    - 20479        Right-to-Left Symbols
     20480    - 20991        Devanagari
     20992    - 21503        Gurmukhi
     21504    - 22015        Gujarati
     22016    - 22527        Oriya
     22528    - 23039        Bengali
     23040    - 23551        Tamil
     23552    - 24063        Telugu
     24064    - 24575        Kannada
     24576    - 25087        Malayalam
     25088    - 25599        Sinhalese
     25600    - 26111        Burmese
     26112    - 26623        Khmer
     26624    - 27135        Thai
     27136    - 27647        Laotian
     27648    - 28159        Georgian
     28160    - 28671        Armenian
     28672    - 29183        Chinese (Simplified)
     29184    - 29695        Tibetan
     29696    - 30207        Mongolian
     30208    - 30719        Geez/Ethiopic
     30720    - 31231        Central European Roman
     31232    - 31743        Vietnamese
     31744    - 32255        Extended Arabic
     32256    - 32767        Uninterpreted Symbols  */
    static func scriptID(for fondID: ResID) -> MacScriptID {
        if fondID < 16384 {
            return .roman
        } else if fondID < 16896 {
            return .japanese
        } else if fondID < 17408 {
            return .traditionalChinese
        } else if fondID < 17920 {
            return .korean
        } else if fondID < 18432 {
            return .arabic
        } else if fondID < 18944 {
            return .hebrew
        } else if fondID < 19456 {
            return .greek
        } else if fondID < 19968 {
            return .cyrillic
        } else if fondID < 20480 {
            return .rightToLeftSymbol
        } else if fondID < 20992 {
            return .devanagari
        } else if fondID < 21504 {
            return .gurmukhi
        } else if fondID < 22016 {
            return .gujarati
        } else if fondID < 22528 {
            return .oriya
        } else if fondID < 23040 {
            return .bengali
        } else if fondID < 23552 {
            return .tamil
        } else if fondID < 24064 {
            return .telugu
        } else if fondID < 24576 {
            return .kannada
        } else if fondID < 25088 {
            return .malayalam
        } else if fondID < 25600 {
            return .sinhalese
        } else if fondID < 26112 {
            return .burmese
        } else if fondID < 26624 {
            return .khmer
        } else if fondID < 27136 {
            return .thai
        } else if fondID < 27648 {
            return .laotian
        } else if fondID < 28160 {
            return .georgian
        } else if fondID < 28672 {
            return .armenian
        } else if fondID < 29184 {
            return .simplifiedChinese
        } else if fondID < 29696 {
            return .tibetan
        } else if fondID < 30208 {
            return .mongolian
        } else if fondID < 30720 {
            return .geez
        } else if fondID < 31232 {
            return .ceRoman
        } else if fondID < 31744 {
            return .vietnamese
        } else if fondID < 32256 {
            return .extendedArabic
        } else if fondID <= ResID.max {
            return .uninterpreted
        }
    }

    var description: String {
        var descriptions: [String] = []
        for i in 0..<CharCode.max {
            if let glyphName = customCharCodesToGlyphNames?[CharCode(i)] {
                descriptions.append("\(i): \(glyphName)")
            }
        }
        return "MacEncoding(\(descriptions.count) glyphs): [\(descriptions.joined(separator: ",\n"))]"
    }

    private var customCharCodesToGlyphNames: [CharCode: String]?
    private let encoding: [UVBMP]

    fileprivate static let symbolPSName     = "Symbol"
    fileprivate static let dingbatsPSName1  = "ZapfDingbatsITC"
    fileprivate static let dingbatsPSName2  = "ZapfDingbats"
}

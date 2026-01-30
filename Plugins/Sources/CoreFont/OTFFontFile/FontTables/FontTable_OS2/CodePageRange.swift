//
//  CodePageRange.swift
//  CoreFont
//
//  Created by Mark Douma on 1/29/2026.
//

import Foundation

public extension FontTable_OS2 {

    struct CodePageRange: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let latin1252:                CodePageRange = .init(rawValue: 0)
        public static let latin2EasternEurope1250:  CodePageRange = .init(rawValue: 1)
        public static let cyrillic1251:             CodePageRange = .init(rawValue: 2)
        public static let greek1253:                CodePageRange = .init(rawValue: 3)
        public static let turkish1254:              CodePageRange = .init(rawValue: 4)
        public static let hebrew1255:               CodePageRange = .init(rawValue: 5)
        public static let arabic1256:               CodePageRange = .init(rawValue: 6)
        public static let windowsBaltic1257:        CodePageRange = .init(rawValue: 7)
        public static let vietnamese1258:           CodePageRange = .init(rawValue: 8)
        public static let reserved9:                CodePageRange = .init(rawValue: 9)
        public static let reserved10:               CodePageRange = .init(rawValue: 10)
        public static let reserved11:               CodePageRange = .init(rawValue: 11)
        public static let reserved12:               CodePageRange = .init(rawValue: 12)
        public static let reserved13:               CodePageRange = .init(rawValue: 13)
        public static let reserved14:               CodePageRange = .init(rawValue: 14)
        public static let reserved15:               CodePageRange = .init(rawValue: 15)
        public static let thai874:                  CodePageRange = .init(rawValue: 16)
        public static let jisJapan932:              CodePageRange = .init(rawValue: 17)
        public static let chineseSimplified936:     CodePageRange = .init(rawValue: 18)
        public static let koreanWansung949:         CodePageRange = .init(rawValue: 19)
        public static let chineseTraditional950:    CodePageRange = .init(rawValue: 20)
        public static let koreanJohab1361:          CodePageRange = .init(rawValue: 21)
        public static let reserved22:               CodePageRange = .init(rawValue: 22)
        public static let reserved23:               CodePageRange = .init(rawValue: 23)
        public static let reserved24:               CodePageRange = .init(rawValue: 24)
        public static let reserved25:               CodePageRange = .init(rawValue: 25)
        public static let reserved26:               CodePageRange = .init(rawValue: 26)
        public static let reserved27:               CodePageRange = .init(rawValue: 27)
        public static let reserved28:               CodePageRange = .init(rawValue: 28)
        public static let macOSRoman:               CodePageRange = .init(rawValue: 29)
        public static let oem:                      CodePageRange = .init(rawValue: 30)
        public static let symbol:                   CodePageRange = .init(rawValue: 31)
        public static let reservedOEM32:            CodePageRange = .init(rawValue: 32)
        public static let reservedOEM33:            CodePageRange = .init(rawValue: 33)
        public static let reservedOEM34:            CodePageRange = .init(rawValue: 34)
        public static let reservedOEM35:            CodePageRange = .init(rawValue: 35)
        public static let reservedOEM36:            CodePageRange = .init(rawValue: 36)
        public static let reservedOEM37:            CodePageRange = .init(rawValue: 37)
        public static let reservedOEM38:            CodePageRange = .init(rawValue: 38)
        public static let reservedOEM39:            CodePageRange = .init(rawValue: 39)
        public static let reservedOEM40:            CodePageRange = .init(rawValue: 40)
        public static let reservedOEM41:            CodePageRange = .init(rawValue: 41)
        public static let reservedOEM42:            CodePageRange = .init(rawValue: 42)
        public static let reservedOEM43:            CodePageRange = .init(rawValue: 43)
        public static let reservedOEM44:            CodePageRange = .init(rawValue: 44)
        public static let reservedOEM45:            CodePageRange = .init(rawValue: 45)
        public static let reservedOEM46:            CodePageRange = .init(rawValue: 46)
        public static let reserved47:               CodePageRange = .init(rawValue: 47)
        public static let ibmGreek869:              CodePageRange = .init(rawValue: 48)
        public static let msDOSRussian866:          CodePageRange = .init(rawValue: 49)
        public static let msDOSNordic865:           CodePageRange = .init(rawValue: 50)
        public static let arabic864:                CodePageRange = .init(rawValue: 51)
        public static let msDOSCanadianFrench863:   CodePageRange = .init(rawValue: 52)
        public static let hebrew862:                CodePageRange = .init(rawValue: 53)
        public static let msDOSIcelandic861:        CodePageRange = .init(rawValue: 54)
        public static let msDOSPortuguese860:       CodePageRange = .init(rawValue: 55)
        public static let ibmTurkish857:            CodePageRange = .init(rawValue: 56)
        public static let ibmCyrillicRussian855:    CodePageRange = .init(rawValue: 57)
        public static let latin2_852:               CodePageRange = .init(rawValue: 58)
        public static let msDOSBaltic775:           CodePageRange = .init(rawValue: 59)
        public static let greek737:                 CodePageRange = .init(rawValue: 60)
        public static let arabicASMO708:            CodePageRange = .init(rawValue: 61)
        public static let wELatin1_850:             CodePageRange = .init(rawValue: 62)
        public static let us437:                    CodePageRange = .init(rawValue: 63)
        public static let none:                     CodePageRange = .init(rawValue: Int.max)
    }

    struct CodePageMask1 : OptionSet {
        public let rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let none:                     CodePageMask1 = .init(rawValue: 0)
        public static let latin1252:                CodePageMask1 = .init(rawValue: 1 << CodePageRange.latin1252.rawValue)
        public static let latin2EasternEurope1250:  CodePageMask1 = .init(rawValue: 1 << CodePageRange.latin2EasternEurope1250.rawValue)
        public static let cyrillic1251:             CodePageMask1 = .init(rawValue: 1 << CodePageRange.cyrillic1251.rawValue)
        public static let greek1253:                CodePageMask1 = .init(rawValue: 1 << CodePageRange.greek1253.rawValue)
        public static let turkish1254:              CodePageMask1 = .init(rawValue: 1 << CodePageRange.turkish1254.rawValue)
        public static let hebrew1255:               CodePageMask1 = .init(rawValue: 1 << CodePageRange.hebrew1255.rawValue)
        public static let arabic1256:               CodePageMask1 = .init(rawValue: 1 << CodePageRange.arabic1256.rawValue)
        public static let windowsBaltic1257:        CodePageMask1 = .init(rawValue: 1 << CodePageRange.windowsBaltic1257.rawValue)
        public static let vietnamese1258:           CodePageMask1 = .init(rawValue: 1 << CodePageRange.vietnamese1258.rawValue)
        public static let reserved9:                CodePageMask1 = .init(rawValue: 1 << CodePageRange.reserved9.rawValue)
        public static let reserved10:               CodePageMask1 = .init(rawValue: 1 << CodePageRange.reserved10.rawValue)
        public static let reserved11:               CodePageMask1 = .init(rawValue: 1 << CodePageRange.reserved11.rawValue)
        public static let reserved12:               CodePageMask1 = .init(rawValue: 1 << CodePageRange.reserved12.rawValue)
        public static let reserved13:               CodePageMask1 = .init(rawValue: 1 << CodePageRange.reserved13.rawValue)
        public static let reserved14:               CodePageMask1 = .init(rawValue: 1 << CodePageRange.reserved14.rawValue)
        public static let reserved15:               CodePageMask1 = .init(rawValue: 1 << CodePageRange.reserved15.rawValue)
        public static let thai874:                  CodePageMask1 = .init(rawValue: 1 << CodePageRange.thai874.rawValue)
        public static let jisJapan932:              CodePageMask1 = .init(rawValue: 1 << CodePageRange.jisJapan932.rawValue)
        public static let chineseSimplified936:     CodePageMask1 = .init(rawValue: 1 << CodePageRange.chineseSimplified936.rawValue)
        public static let koreanWansung949:         CodePageMask1 = .init(rawValue: 1 << CodePageRange.koreanWansung949.rawValue)
        public static let chineseTraditional950:    CodePageMask1 = .init(rawValue: 1 << CodePageRange.chineseTraditional950.rawValue)
        public static let koreanJohab1361:          CodePageMask1 = .init(rawValue: 1 << CodePageRange.koreanJohab1361.rawValue)
        public static let reserved22:               CodePageMask1 = .init(rawValue: 1 << CodePageRange.reserved22.rawValue)
        public static let reserved23:               CodePageMask1 = .init(rawValue: 1 << CodePageRange.reserved23.rawValue)
        public static let reserved24:               CodePageMask1 = .init(rawValue: 1 << CodePageRange.reserved24.rawValue)
        public static let reserved25:               CodePageMask1 = .init(rawValue: 1 << CodePageRange.reserved25.rawValue)
        public static let reserved26:               CodePageMask1 = .init(rawValue: 1 << CodePageRange.reserved26.rawValue)
        public static let reserved27:               CodePageMask1 = .init(rawValue: 1 << CodePageRange.reserved27.rawValue)
        public static let reserved28:               CodePageMask1 = .init(rawValue: 1 << CodePageRange.reserved28.rawValue)
        public static let macOSRoman:               CodePageMask1 = .init(rawValue: 1 << CodePageRange.macOSRoman.rawValue)
        public static let oem:                      CodePageMask1 = .init(rawValue: 1 << CodePageRange.oem.rawValue)
        public static let symbol:                   CodePageMask1 = .init(rawValue: 1 << CodePageRange.symbol.rawValue)
    }

    struct CodePageMask2: OptionSet {
        public let rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        public static let reservedOEM32:            CodePageMask2 = .init(rawValue: 1 << (CodePageRange.reservedOEM32.rawValue % 32))
        public static let reservedOEM33:            CodePageMask2 = .init(rawValue: 1 << (CodePageRange.reservedOEM33.rawValue % 32))
        public static let reservedOEM34:            CodePageMask2 = .init(rawValue: 1 << (CodePageRange.reservedOEM34.rawValue % 32))
        public static let reservedOEM35:            CodePageMask2 = .init(rawValue: 1 << (CodePageRange.reservedOEM35.rawValue % 32))
        public static let reservedOEM36:            CodePageMask2 = .init(rawValue: 1 << (CodePageRange.reservedOEM36.rawValue % 32))
        public static let reservedOEM37:            CodePageMask2 = .init(rawValue: 1 << (CodePageRange.reservedOEM37.rawValue % 32))
        public static let reservedOEM38:            CodePageMask2 = .init(rawValue: 1 << (CodePageRange.reservedOEM38.rawValue % 32))
        public static let reservedOEM39:            CodePageMask2 = .init(rawValue: 1 << (CodePageRange.reservedOEM39.rawValue % 32))
        public static let reservedOEM40:            CodePageMask2 = .init(rawValue: 1 << (CodePageRange.reservedOEM40.rawValue % 32))
        public static let reservedOEM41:            CodePageMask2 = .init(rawValue: 1 << (CodePageRange.reservedOEM41.rawValue % 32))
        public static let reservedOEM42:            CodePageMask2 = .init(rawValue: 1 << (CodePageRange.reservedOEM42.rawValue % 32))
        public static let reservedOEM43:            CodePageMask2 = .init(rawValue: 1 << (CodePageRange.reservedOEM43.rawValue % 32))
        public static let reservedOEM44:            CodePageMask2 = .init(rawValue: 1 << (CodePageRange.reservedOEM44.rawValue % 32))
        public static let reservedOEM45:            CodePageMask2 = .init(rawValue: 1 << (CodePageRange.reservedOEM45.rawValue % 32))
        public static let reservedOEM46:            CodePageMask2 = .init(rawValue: 1 << (CodePageRange.reservedOEM46.rawValue % 32))
        public static let reserved47:               CodePageMask2 = .init(rawValue: 1 << (CodePageRange.reserved47.rawValue % 32))
        public static let ibmGreek869:              CodePageMask2 = .init(rawValue: 1 << (CodePageRange.ibmGreek869.rawValue % 32))
        public static let msDOSRussian866:          CodePageMask2 = .init(rawValue: 1 << (CodePageRange.msDOSRussian866.rawValue % 32))
        public static let msDOSNordic865:           CodePageMask2 = .init(rawValue: 1 << (CodePageRange.msDOSNordic865.rawValue % 32))
        public static let arabic864:                CodePageMask2 = .init(rawValue: 1 << (CodePageRange.arabic864.rawValue % 32))
        public static let msDOSCanadianFrench863:   CodePageMask2 = .init(rawValue: 1 << (CodePageRange.msDOSCanadianFrench863.rawValue % 32))
        public static let hebrew862:                CodePageMask2 = .init(rawValue: 1 << (CodePageRange.hebrew862.rawValue % 32))
        public static let msDOSIcelandic861:        CodePageMask2 = .init(rawValue: 1 << (CodePageRange.msDOSIcelandic861.rawValue % 32))
        public static let msDOSPortuguese860:       CodePageMask2 = .init(rawValue: 1 << (CodePageRange.msDOSPortuguese860.rawValue % 32))
        public static let ibmTurkish857:            CodePageMask2 = .init(rawValue: 1 << (CodePageRange.ibmTurkish857.rawValue % 32))
        public static let ibmCyrillicRussian855:    CodePageMask2 = .init(rawValue: 1 << (CodePageRange.ibmCyrillicRussian855.rawValue % 32))
        public static let latin2_852:               CodePageMask2 = .init(rawValue: 1 << (CodePageRange.latin2_852.rawValue % 32))
        public static let msDOSBaltic775:           CodePageMask2 = .init(rawValue: 1 << (CodePageRange.msDOSBaltic775.rawValue % 32))
        public static let greek737:                 CodePageMask2 = .init(rawValue: 1 << (CodePageRange.greek737.rawValue % 32))
        public static let arabicASMO708:            CodePageMask2 = .init(rawValue: 1 << (CodePageRange.arabicASMO708.rawValue % 32))
        public static let wELatin1_850:             CodePageMask2 = .init(rawValue: 1 << (CodePageRange.wELatin1_850.rawValue % 32))
        public static let us437:                    CodePageMask2 = .init(rawValue: 1 << (CodePageRange.us437.rawValue % 32))
    }
}

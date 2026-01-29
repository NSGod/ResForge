//
//  UnicodeRange.swift
//  CoreFont
//
//  Created by Mark Douma on 1/29/2026.
//

import Foundation

public extension FontTable_OS2 {

    struct UnicodeRange: OptionSet {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let basicLatin                              = 0
        public static let latin1Supplement                        = 1
        public static let latinExtendedA                          = 2
        public static let latinExtendedB                          = 3
        public static let ipaPhoneticExtensions                   = 4
        public static let spacingModifierLetters                  = 5
        public static let combiningDiacriticalMarks               = 6
        public static let greekAndCoptic                          = 7
        public static let coptic                                  = 8
        public static let cyrillic                                = 9
        public static let armenian                                = 10
        public static let hebrew                                  = 11
        public static let vai                                     = 12
        public static let arabic                                  = 13
        public static let nKo                                     = 14
        public static let devangari                               = 15
        public static let bengali                                 = 16
        public static let gurmukhi                                = 17
        public static let gujarati                                = 18
        public static let oriya                                   = 19
        public static let tamil                                   = 20
        public static let telegu                                  = 21
        public static let kannada                                 = 22
        public static let malayalam                               = 23
        public static let thai                                    = 24
        public static let lao                                     = 25
        public static let georgian                                = 26
        public static let balinese                                = 27
        public static let hangulJamo                              = 28
        public static let latinExtended                           = 29
        public static let greekExtended                           = 30
        public static let generalPunctuation                      = 31
        public static let superscriptsAndSubscripts               = 32
        public static let currencySymbols                         = 33
        public static let combiningDiacriticalMarksForSymbols     = 34
        public static let letterlikeSymbols                       = 35
        public static let numberForms                             = 36
        public static let arrows                                  = 37
        public static let mathematicalOperators                   = 38
        public static let miscTechnical                           = 39
        public static let controlPictures                         = 40
        public static let ocr                                     = 41
        public static let enclosedAlphanumerics                   = 42
        public static let boxDrawing                              = 43
        public static let blockElements                           = 44
        public static let geometricShapes                         = 45
        public static let miscSymbols                             = 46
        public static let dingbats                                = 47
        public static let cjkSymbolsAndPunctuation                = 48
        public static let hiragana                                = 49
        public static let katakana                                = 50
        public static let bopomofo                                = 51
        public static let hangulCompatibilityJamo                 = 52
        public static let phagsPa                                 = 53
        public static let enclosedCJKLettersAndMonths             = 54
        public static let cjkCompatibility                        = 55
        public static let hangulSyllables                         = 56
        public static let nonPlane0                               = 57
        public static let phoenician                              = 58
        public static let cjkUnifiedIdeographs                    = 59
        public static let privateUseAreaPlane0                    = 60
        public static let cjkStrokesAndCompatibilityIdeographs    = 61
        public static let alphabeticPresentationForms             = 62
        public static let arabicPresentationFormsA                = 63
        public static let combiningHalfMarks                      = 64
        public static let verticalAndCJKCompatabilityForms        = 65
        public static let smallFormVariants                       = 66
        public static let arabicPresentationFormsB                = 67
        public static let halfwidthAndFullwidthForms              = 68
        public static let specials                                = 69
        public static let tibetan                                 = 70
        public static let syriac                                  = 71
        public static let thaana                                  = 72
        public static let sinhala                                 = 73
        public static let myanmar                                 = 74
        public static let ethiopic                                = 75
        public static let cherokee                                = 76
        public static let unitedCanadianAboriginalSyllabics       = 77
        public static let ogham                                   = 78
        public static let runic                                   = 79
        public static let khmer                                   = 80
        public static let mongolian                               = 81
        public static let braillePatterns                         = 82
        public static let yi                                      = 83
        public static let tagalogHanunooBuhidTagbanwa             = 84
        public static let oldItalic                               = 85
        public static let gothic                                  = 86
        public static let deseret                                 = 87
        public static let musicalSymbols                          = 88
        public static let mathematicalAlphanumericSymbols         = 89
        public static let privateUsePlanes15_16                   = 90
        public static let variationSelectors                      = 91
        public static let tags                                    = 92
        public static let limbu                                   = 93
        public static let taiLe                                   = 94
        public static let newTaiLue                               = 95
        public static let buginese                                = 96
        public static let glagolitic                              = 97
        public static let tifinagh                                = 98
        public static let yijingHexagramSymbols                   = 99
        public static let sylotiNagri                             = 100
        public static let linearB                                 = 101
        public static let ancientGreekNumbers                     = 102
        public static let ugaritic                                = 103
        public static let oldPersian                              = 104
        public static let shavian                                 = 105
        public static let osmanya                                 = 106
        public static let cypriotSyllabary                        = 107
        public static let kharoshthi                              = 108
        public static let taiXuanJingSymbols                      = 109
        public static let cuneiform                               = 110
        public static let countingRodNumerals                     = 111
        public static let sundanese                               = 112
        public static let lepcha                                  = 113
        public static let olChiki                                 = 114
        public static let saurashtra                              = 115
        public static let kayahLi                                 = 116
        public static let rejang                                  = 117
        public static let cham                                    = 118
        public static let ancientSymbols                          = 119
        public static let phaistosDisc                            = 120
        public static let carianLycianLydian                      = 121
        public static let dominoAndMahjongTiles                   = 122
        public static let none                                    = UInt32.max
    }

    struct UnicodeMask1: OptionSet {
        public let rawValue: UInt64
        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }

        public static let basicLatin: UnicodeMask1                              = .init(rawValue: 1 << UnicodeRange.basicLatin)
        public static let latin1Supplement: UnicodeMask1                        = .init(rawValue: 1 << UnicodeRange.latin1Supplement)
        public static let latinExtendedA: UnicodeMask1                          = .init(rawValue: 1 << UnicodeRange.latinExtendedA)
        public static let latinExtendedB: UnicodeMask1                          = .init(rawValue: 1 << UnicodeRange.latinExtendedB)
        public static let ipaPhoneticExtensions: UnicodeMask1                   = .init(rawValue: 1 << UnicodeRange.ipaPhoneticExtensions)
        public static let spacingModifierLetters: UnicodeMask1                  = .init(rawValue: 1 << UnicodeRange.spacingModifierLetters)
        public static let combiningDiacriticalMarks: UnicodeMask1               = .init(rawValue: 1 << UnicodeRange.combiningDiacriticalMarks)
        public static let greekAndCoptic: UnicodeMask1                          = .init(rawValue: 1 << UnicodeRange.greekAndCoptic)
        public static let coptic: UnicodeMask1                                  = .init(rawValue: 1 << UnicodeRange.coptic)
        public static let cyrillic: UnicodeMask1                                = .init(rawValue: 1 << UnicodeRange.cyrillic)
        public static let armenian: UnicodeMask1                                = .init(rawValue: 1 << UnicodeRange.armenian)
        public static let hebrew: UnicodeMask1                                  = .init(rawValue: 1 << UnicodeRange.hebrew)
        public static let vai: UnicodeMask1                                     = .init(rawValue: 1 << UnicodeRange.vai)
        public static let arabic: UnicodeMask1                                  = .init(rawValue: 1 << UnicodeRange.arabic)
        public static let nKo: UnicodeMask1                                     = .init(rawValue: 1 << UnicodeRange.nKo)
        public static let devangari: UnicodeMask1                               = .init(rawValue: 1 << UnicodeRange.devangari)
        public static let bengali: UnicodeMask1                                 = .init(rawValue: 1 << UnicodeRange.bengali)
        public static let gurmukhi: UnicodeMask1                                = .init(rawValue: 1 << UnicodeRange.gurmukhi)
        public static let gujarati: UnicodeMask1                                = .init(rawValue: 1 << UnicodeRange.gujarati)
        public static let oriya: UnicodeMask1                                   = .init(rawValue: 1 << UnicodeRange.oriya)
        public static let tamil: UnicodeMask1                                   = .init(rawValue: 1 << UnicodeRange.tamil)
        public static let telegu: UnicodeMask1                                  = .init(rawValue: 1 << UnicodeRange.telegu)
        public static let kannada: UnicodeMask1                                 = .init(rawValue: 1 << UnicodeRange.kannada)
        public static let malayalam: UnicodeMask1                               = .init(rawValue: 1 << UnicodeRange.malayalam)
        public static let thai: UnicodeMask1                                    = .init(rawValue: 1 << UnicodeRange.thai)
        public static let lao: UnicodeMask1                                     = .init(rawValue: 1 << UnicodeRange.lao)
        public static let georgian: UnicodeMask1                                = .init(rawValue: 1 << UnicodeRange.georgian)
        public static let balinese: UnicodeMask1                                = .init(rawValue: 1 << UnicodeRange.balinese)
        public static let hangulJamo: UnicodeMask1                              = .init(rawValue: 1 << UnicodeRange.hangulJamo)
        public static let latinExtended: UnicodeMask1                           = .init(rawValue: 1 << UnicodeRange.latinExtended)
        public static let greekExtended: UnicodeMask1                           = .init(rawValue: 1 << UnicodeRange.greekExtended)
        public static let generalPunctuation: UnicodeMask1                      = .init(rawValue: 1 << UnicodeRange.generalPunctuation)
        public static let cuperscriptsAndSubscripts: UnicodeMask1               = .init(rawValue: 1 << UnicodeRange.superscriptsAndSubscripts)
        public static let currencySymbols: UnicodeMask1                         = .init(rawValue: 1 << UnicodeRange.currencySymbols)
        public static let combiningDiacriticalMarksForSymbols: UnicodeMask1     = .init(rawValue: 1 << UnicodeRange.combiningDiacriticalMarksForSymbols)
        public static let letterlikeSymbols: UnicodeMask1                       = .init(rawValue: 1 << UnicodeRange.letterlikeSymbols)
        public static let numberForms: UnicodeMask1                             = .init(rawValue: 1 << UnicodeRange.numberForms)
        public static let arrows: UnicodeMask1                                  = .init(rawValue: 1 << UnicodeRange.arrows)
        public static let mathematicalOperators: UnicodeMask1                   = .init(rawValue: 1 << UnicodeRange.mathematicalOperators)
        public static let miscTechnical: UnicodeMask1                           = .init(rawValue: 1 << UnicodeRange.miscTechnical)
        public static let controlPictures: UnicodeMask1                         = .init(rawValue: 1 << UnicodeRange.controlPictures)
        public static let ocr: UnicodeMask1                                     = .init(rawValue: 1 << UnicodeRange.ocr)
        public static let enclosedAlphanumerics: UnicodeMask1                   = .init(rawValue: 1 << UnicodeRange.enclosedAlphanumerics)
        public static let boxDrawing: UnicodeMask1                              = .init(rawValue: 1 << UnicodeRange.boxDrawing)
        public static let blockElements: UnicodeMask1                           = .init(rawValue: 1 << UnicodeRange.blockElements)
        public static let geometricShapes: UnicodeMask1                         = .init(rawValue: 1 << UnicodeRange.geometricShapes)
        public static let miscSymbols: UnicodeMask1                             = .init(rawValue: 1 << UnicodeRange.miscSymbols)
        public static let dingbats: UnicodeMask1                                = .init(rawValue: 1 << UnicodeRange.dingbats)
        public static let cjkSymbolsAndPunctuation: UnicodeMask1                = .init(rawValue: 1 << UnicodeRange.cjkSymbolsAndPunctuation)
        public static let hiragana: UnicodeMask1                                = .init(rawValue: 1 << UnicodeRange.hiragana)
        public static let katakana: UnicodeMask1                                = .init(rawValue: 1 << UnicodeRange.katakana)
        public static let bopomofo: UnicodeMask1                                = .init(rawValue: 1 << UnicodeRange.bopomofo)
        public static let hangulCompatibilityJamo: UnicodeMask1                 = .init(rawValue: 1 << UnicodeRange.hangulCompatibilityJamo)
        public static let phagsPa: UnicodeMask1                                 = .init(rawValue: 1 << UnicodeRange.phagsPa)
        public static let enclosedCJKLettersAndMonths: UnicodeMask1             = .init(rawValue: 1 << UnicodeRange.enclosedCJKLettersAndMonths)
        public static let cjkCompatibility: UnicodeMask1                        = .init(rawValue: 1 << UnicodeRange.cjkCompatibility)
        public static let hangulSyllables: UnicodeMask1                         = .init(rawValue: 1 << UnicodeRange.hangulSyllables)
        public static let nonPlane0: UnicodeMask1                               = .init(rawValue: 1 << UnicodeRange.nonPlane0)
        public static let phoenician: UnicodeMask1                              = .init(rawValue: 1 << UnicodeRange.phoenician)
        public static let cjkUnifiedIdeographs: UnicodeMask1                    = .init(rawValue: 1 << UnicodeRange.cjkUnifiedIdeographs)
        public static let privateUseAreaPlane0: UnicodeMask1                    = .init(rawValue: 1 << UnicodeRange.privateUseAreaPlane0)
        public static let cjkStrokesAndCompatibilityIdeographs: UnicodeMask1    = .init(rawValue: 1 << UnicodeRange.cjkStrokesAndCompatibilityIdeographs)
        public static let alphabeticPresentationForms: UnicodeMask1             = .init(rawValue: 1 << UnicodeRange.alphabeticPresentationForms)
        public static let arabicPresentationFormsA: UnicodeMask1                = .init(rawValue: 1 << UnicodeRange.arabicPresentationFormsA)
    }

    struct UnicodeMask2: OptionSet {
        public let rawValue: UInt64
        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }

        public static let combiningHalfMarks: UnicodeMask2                  = .init(rawValue: 1 << (UnicodeRange.combiningHalfMarks % 64))
        public static let verticalAndCJKCompatabilityForms: UnicodeMask2    = .init(rawValue: 1 << (UnicodeRange.verticalAndCJKCompatabilityForms % 64))
        public static let smallFormVariants: UnicodeMask2                   = .init(rawValue: 1 << (UnicodeRange.smallFormVariants % 64))
        public static let arabicPresentationFormsB: UnicodeMask2            = .init(rawValue: 1 << (UnicodeRange.arabicPresentationFormsB % 64))
        public static let halfwidthAndFullwidthForms: UnicodeMask2          = .init(rawValue: 1 << (UnicodeRange.halfwidthAndFullwidthForms % 64))
        public static let specials: UnicodeMask2                            = .init(rawValue: 1 << (UnicodeRange.specials % 64))
        public static let tibetan: UnicodeMask2                             = .init(rawValue: 1 << (UnicodeRange.tibetan % 64))
        public static let syriac: UnicodeMask2                              = .init(rawValue: 1 << (UnicodeRange.syriac % 64))
        public static let thaana: UnicodeMask2                              = .init(rawValue: 1 << (UnicodeRange.thaana % 64))
        public static let sinhala: UnicodeMask2                             = .init(rawValue: 1 << (UnicodeRange.sinhala % 64))
        public static let myanmar: UnicodeMask2                             = .init(rawValue: 1 << (UnicodeRange.myanmar % 64))
        public static let ethiopic: UnicodeMask2                            = .init(rawValue: 1 << (UnicodeRange.ethiopic % 64))
        public static let cherokee: UnicodeMask2                            = .init(rawValue: 1 << (UnicodeRange.cherokee % 64))
        public static let unitedCanadianAboriginalSyllabics: UnicodeMask2   = .init(rawValue: 1 << (UnicodeRange.unitedCanadianAboriginalSyllabics % 64))
        public static let ogham: UnicodeMask2                               = .init(rawValue: 1 << (UnicodeRange.ogham % 64))
        public static let runic: UnicodeMask2                               = .init(rawValue: 1 << (UnicodeRange.runic % 64))
        public static let khmer: UnicodeMask2                               = .init(rawValue: 1 << (UnicodeRange.khmer % 64))
        public static let mongolian: UnicodeMask2                           = .init(rawValue: 1 << (UnicodeRange.mongolian % 64))
        public static let braillePatterns: UnicodeMask2                     = .init(rawValue: 1 << (UnicodeRange.braillePatterns % 64))
        public static let yi: UnicodeMask2                                  = .init(rawValue: 1 << (UnicodeRange.yi % 64))
        public static let tagalogHanunooBuhidTagbanwa: UnicodeMask2         = .init(rawValue: 1 << (UnicodeRange.tagalogHanunooBuhidTagbanwa % 64))
        public static let oldItalic: UnicodeMask2                           = .init(rawValue: 1 << (UnicodeRange.oldItalic % 64))
        public static let gothic: UnicodeMask2                              = .init(rawValue: 1 << (UnicodeRange.gothic % 64))
        public static let deseret: UnicodeMask2                             = .init(rawValue: 1 << (UnicodeRange.deseret % 64))
        public static let musicalSymbols: UnicodeMask2                      = .init(rawValue: 1 << (UnicodeRange.musicalSymbols % 64))
        public static let mathematicalAlphanumericSymbols: UnicodeMask2     = .init(rawValue: 1 << (UnicodeRange.mathematicalAlphanumericSymbols % 64))
        public static let privateUsePlanes15_16: UnicodeMask2               = .init(rawValue: 1 << (UnicodeRange.privateUsePlanes15_16 % 64))
        public static let variationSelectors: UnicodeMask2                  = .init(rawValue: 1 << (UnicodeRange.variationSelectors % 64))
        public static let tags: UnicodeMask2                                = .init(rawValue: 1 << (UnicodeRange.tags % 64))
        public static let limbu: UnicodeMask2                               = .init(rawValue: 1 << (UnicodeRange.limbu % 64))
        public static let taiLe: UnicodeMask2                               = .init(rawValue: 1 << (UnicodeRange.taiLe % 64))
        public static let newTaiLue: UnicodeMask2                           = .init(rawValue: 1 << (UnicodeRange.newTaiLue % 64))
        public static let buginese: UnicodeMask2                            = .init(rawValue: 1 << (UnicodeRange.buginese % 64))
        public static let glagolitic: UnicodeMask2                          = .init(rawValue: 1 << (UnicodeRange.glagolitic % 64))
        public static let tifinagh: UnicodeMask2                            = .init(rawValue: 1 << (UnicodeRange.tifinagh % 64))
        public static let yijingHexagramSymbols: UnicodeMask2               = .init(rawValue: 1 << (UnicodeRange.yijingHexagramSymbols % 64))
        public static let sylotiNagri: UnicodeMask2                         = .init(rawValue: 1 << (UnicodeRange.sylotiNagri % 64))
        public static let linearB: UnicodeMask2                             = .init(rawValue: 1 << (UnicodeRange.linearB % 64))
        public static let ancientGreekNumbers: UnicodeMask2                 = .init(rawValue: 1 << (UnicodeRange.ancientGreekNumbers % 64))
        public static let ugaritic: UnicodeMask2                            = .init(rawValue: 1 << (UnicodeRange.ugaritic % 64))
        public static let oldPersian: UnicodeMask2                          = .init(rawValue: 1 << (UnicodeRange.oldPersian % 64))
        public static let shavian: UnicodeMask2                             = .init(rawValue: 1 << (UnicodeRange.shavian % 64))
        public static let osmanya: UnicodeMask2                             = .init(rawValue: 1 << (UnicodeRange.osmanya % 64))
        public static let cypriotSyllabary: UnicodeMask2                    = .init(rawValue: 1 << (UnicodeRange.cypriotSyllabary % 64))
        public static let kharoshthi: UnicodeMask2                          = .init(rawValue: 1 << (UnicodeRange.kharoshthi % 64))
        public static let taiXuanJingSymbols: UnicodeMask2                  = .init(rawValue: 1 << (UnicodeRange.taiXuanJingSymbols % 64))
        public static let cuneiform: UnicodeMask2                           = .init(rawValue: 1 << (UnicodeRange.cuneiform % 64))
        public static let countingRodNumerals: UnicodeMask2                 = .init(rawValue: 1 << (UnicodeRange.countingRodNumerals % 64))
        public static let sundanese: UnicodeMask2                           = .init(rawValue: 1 << (UnicodeRange.sundanese % 64))
        public static let lepcha: UnicodeMask2                              = .init(rawValue: 1 << (UnicodeRange.lepcha % 64))
        public static let olChiki: UnicodeMask2                             = .init(rawValue: 1 << (UnicodeRange.olChiki % 64))
        public static let saurashtra: UnicodeMask2                          = .init(rawValue: 1 << (UnicodeRange.saurashtra % 64))
        public static let kayahLi: UnicodeMask2                             = .init(rawValue: 1 << (UnicodeRange.kayahLi % 64))
        public static let rejang: UnicodeMask2                              = .init(rawValue: 1 << (UnicodeRange.rejang % 64))
        public static let cham: UnicodeMask2                                = .init(rawValue: 1 << (UnicodeRange.cham % 64))
        public static let ancientSymbols: UnicodeMask2                      = .init(rawValue: 1 << (UnicodeRange.ancientSymbols % 64))
        public static let phaistosDisc: UnicodeMask2                        = .init(rawValue: 1 << (UnicodeRange.phaistosDisc % 64))
        public static let carianLycianLydian: UnicodeMask2                  = .init(rawValue: 1 << (UnicodeRange.carianLycianLydian % 64))
        public static let dominoAndMahjongTiles: UnicodeMask2               = .init(rawValue: 1 << (UnicodeRange.dominoAndMahjongTiles % 64))
    }
}

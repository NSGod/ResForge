//
//  FONDError.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/4/2026.
//

import Foundation

enum FONDError: LocalizedError {
    case noFontAssociationTableEntries
    case fontAssociationTableEntriesInvalid
    case fontAssociationTableEntriesNotAscending
    case fontAssociationTableEntriesRefSameFont
    case firstResourceNameIsZeroLength
    case noName
    case invalidCharRange
    case invalidWidthTableOffset
    case invalidKerningTableOffset
    case invalidStyleMappingTableOffset
    case lengthTooShort
    case offsetTableUsability
    case boundingBoxTableUsability
    case widthTableUsability
    case styleMappingTableUsability
    case fontNameSuffixSubtableUsability
    case glyphNameTableUsability
    case kernTableUsability
    case noSuchFontAssociationTableEntry

    var errorDescription: String? {
        switch self {
            case .noFontAssociationTableEntries:
                return NSLocalizedString("The 'FOND' doesn’t contain any font association table entries.", comment: "")
            case .fontAssociationTableEntriesInvalid:
                return NSLocalizedString("The 'FOND' contains invalid font association table entries.", comment: "")
            case .fontAssociationTableEntriesNotAscending:
                return NSLocalizedString("The FOND’s font association table entries aren’t in ascending order.", comment: "")
            case .fontAssociationTableEntriesRefSameFont:
                return NSLocalizedString("Two or more of the FOND’s font association table entries reference the same font.", comment: "")
            case .firstResourceNameIsZeroLength:
                return NSLocalizedString("The first resource name has a zero length.", comment: "")
            case .noName:
                return NSLocalizedString("The 'FOND' resource has no name.", comment: "")
            case .invalidCharRange:
                return NSLocalizedString("The 'FOND' resource has an invalid character range.", comment: "")
            case .invalidWidthTableOffset:
                return NSLocalizedString("The 'FOND' specifies a value for the offset to the font’s width table that is beyond the end of the file.", comment: "")
            case .invalidKerningTableOffset:
                return NSLocalizedString("The 'FOND' specifies a value for the offset to the font’s kerning table that is beyond the end of the file.", comment: "")
            case .invalidStyleMappingTableOffset:
                return NSLocalizedString("The 'FOND' specifies a value for the offset to the font’s style-mapping table that is beyond the end of the file.", comment: "")
            case .lengthTooShort:
                return NSLocalizedString("The length of the 'FOND' resource is too short and doesn’t contain enough data to be usable.", comment: "")
            case .offsetTableUsability:
                return NSLocalizedString("The Offset table is too short and doesn’t contain enough data to be usable.", comment: "")
            case .boundingBoxTableUsability:
                return NSLocalizedString("The Bounding Box table is too short and doesn’t contain enough data to be usable.", comment: "")
            case .widthTableUsability:
                return NSLocalizedString("The Width table is too short and doesn’t contain enough data to be usable.", comment: "")
            case .styleMappingTableUsability:
                return NSLocalizedString("The contents of the 'FOND' style mapping table is damaged and unusable.", comment: "")
            case .fontNameSuffixSubtableUsability:
                return NSLocalizedString("The contents of a 'FOND' style mapping table’s font name suffix subtable is damaged and unusable.", comment: "")
            case .glyphNameTableUsability:
                return NSLocalizedString("The contents of a 'FOND' style mapping table’s glyph name encoding subtable is damaged and unusable.", comment: "")
            case .kernTableUsability:
                return NSLocalizedString("The Kern table is too short and doesn’t contain enough data to be usable.", comment: "")
            case .noSuchFontAssociationTableEntry:
                return NSLocalizedString("The specified font association table entry could not be found.", comment: "")
        }
    }
}


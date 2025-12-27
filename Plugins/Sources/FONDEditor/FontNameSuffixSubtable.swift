//
//  FontNameSuffixSubtable.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/24/2025.
//

import Cocoa
import RFSupport
import Darwin

struct FontNameSuffixSubtable {
    var stringCount:                            Int16

    var baseFontName:                           String
//    var string: Str255

    private var entryIndexesToPostScriptNames:  [UInt8: String]
    private var _actualStringCount:             Int16
}

extension FontNameSuffixSubtable {
    init(_ reader: BinaryDataReader, range knownRange: NSRange) throws {
        stringCount = try reader.read()
        baseFontName = try reader.readPString()

        entryIndexesToPostScriptNames = [:]
//        malloc(T##__size: Int##Int)
//        CFStringCreateWithPascalString(kCFAllocatorDefault, ConstStr255Param!, CFStringEncoding)
    }

    func postScriptNameForFontEntry(at oneBasedIndex: UInt8) -> String? {

    }
}

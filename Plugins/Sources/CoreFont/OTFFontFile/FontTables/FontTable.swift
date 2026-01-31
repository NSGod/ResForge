//
//  FontTable.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport

public enum FontTableError: LocalizedError {
    case unknownVersion(String?)
    case unknownFormat(String?)
    case parseError(String?)
}

/// abstract superclass
open class FontTable: OTFFontFileNode {
    public let tableTag:            TableTag
    public var tableData:           Data
    public var paddedTableData:     Data {
        var paddedData = tableData
        paddedData.count = (paddedData.count + 3 ) & -4
        return paddedData
    }

    public var tableLength:         UInt32 { UInt32(tableData.count) }
    public var paddedTableLength:   UInt32 { UInt32(paddedTableData.count) }

    public var calculatedChecksum:  UInt32 {
        // NSLog("\(type(of: self)).\(#function)")
        let tableLongs: [UInt32] = paddedTableData.withUnsafeBytes{ rawBuffer in
            return rawBuffer.bindMemory(to: UInt32.self).map(\.bigEndian)
        }
        var calcChecksum: UInt32 = 0
        for long in tableLongs {
            calcChecksum &+= long
        }
        return calcChecksum
    }

    class var usesLazyParsing: Bool { true }

    var reader:         BinaryDataReader

    enum ParseState {
        case unparsed
        case parsing
        case parsed
    }
    var parseState:     ParseState = .unparsed

    // MARK: - init
    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        self.tableData = tableData
        self.tableTag = tableTag
        reader = BinaryDataReader(tableData)
        try super.init(fontFile: fontFile)
//        if !Self.usesLazyParsing {
//            try parseTableData()
//        }
    }

    public func parseTableData() throws {
    }

    func parseTableDataIfNeeded() throws {
        if parseState != .unparsed { return }
        parseState = .parsing
        try parseTableData()
        parseState = .parsed
    }

    public static func `class`(for tableTag: TableTag) -> FontTable.Type {
        if tableTag == .OS_2 { return FontTable_OS2.self }
//        if tableTag == .CID_ { return FontTable_CID.self }
//        if tableTag == .cvt_ { return FontTable_cvt.self }
//        if tableTag == .CFF_ { return FontTable_CFF.self }
        if let theClass: FontTable.Type = NSClassFromString("CoreFont.FontTable_\(tableTag.fourCharString)") as? FontTable.Type {
            return theClass
            // if class is Nil, try byte-swapping the table tag to see if it's wrong in the font (i.e. 'SOPG' instead of 'GPOS')
        } else if let theClass: FontTable.Type = NSClassFromString("CoreFont.FontTable_\(tableTag.byteSwapped.fourCharString)") as? FontTable.Type {
            return theClass
        }
        return FontTable.self
    }

    public func table(for tableTag: TableTag) -> FontTable? {
        return fontFile?.table(for: tableTag)
    }

    public var headTable: FontTable_head? { table(for: .head) as? FontTable_head }
    public var maxpTable: FontTable_maxp? { table(for: .maxp) as? FontTable_maxp }
    public var postTable: FontTable_post? { table(for: .post) as? FontTable_post }
    public var nameTable: FontTable_name? { table(for: .name) as? FontTable_name }
    public var hheaTable: FontTable_hhea? { table(for: .hhea) as? FontTable_hhea }
    public var htmxTable: FontTable_hmtx? { table(for: .hmtx) as? FontTable_hmtx }
    public var os2Table:  FontTable_OS2?  { table(for: .OS_2) as? FontTable_OS2 }

    public var fontNumGlyphs: Int {
        return fontFile.numGlyphs
    }

    public func fontGlyphName(for glyphID: Glyph32ID) -> String? {
        return fontFile.glyphName(for: glyphID)
    }
}

/// `Ideally:`
/// immediate parsing:
/// `head`, `maxp`, `OS/2`
///
/// lazy parsing:
/// `cmap`, `hhea`, `hmtx`, `hdmx`,
/// `post`, `vhea`, `vmtx`
/// `name`, `fdsc`, `feat`,
/// `loca`, `glyf`, `fond`, `gasp`, `cvt `,
/// `kern`, `kerx`, `DSIG`, `CFF `, `CFF2`
/// `GPOS`, `GSUB`, `GDEF`,
/// `cvar`, `fvar`, `gvar`,
/// & all others

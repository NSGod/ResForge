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
    case writeError(String?)
}

/// `Ideally:`
/// immediate parsing:
/// `head`/`bhed`, `maxp`, `OS/2`
///
/// lazy parsing:
/// `cmap`, `hhea`, `hmtx`, `hdmx`,
/// `post`, `vhea`, `vmtx`
/// `name`, `fdsc`, `feat`,
/// `loca`, `glyf`, `fond`, `gasp`, `cvt `,
/// `kern`, `kerx`, `DSIG`, `CFF `, `CFF2`
/// `GPOS`, `GSUB`, `GDEF`,
/// `cvar`, `fvar`, `gvar`,
/// `bloc`, `bdat`,
/// & all others

/// abstract superclass
open class FontTable: OTFFontFileNode {
    public let tableTag:            TableTag
    public var tableData:           Data
    public var paddedTableData:     Data {
        var paddedData = tableData
        paddedData.count = paddedData.count.uint32AlignedCount
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

    var reader:         BinaryDataReader
    var dataHandle:     DataHandle!

    // MARK: - init
    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        self.tableData = tableData
        self.tableTag = tableTag
        reader = BinaryDataReader(tableData)
        try super.init(fontFile: fontFile)
    }

    /// give table a chance to update its in memory data structures
    func prepareToWrite() throws {

    }

    /// write those updated data structures to our `dataHandle`
    func write() throws {
        dataHandle.data = tableData
    }

    /// Write our `tableData` to the provided external data handle `handle`, and update
    /// the specified `OTFsfntDirectoryEntry`. To allow subclasses a chance to update their data
    /// before writing, this method first calls the following 2 methods:
    ///
    /// `prepareToWrite()` - allows subclasses to update any internal data structures
    /// `write()` - allows subclasses to write that updated data back into their own `tableData`
    ///
    /// This method then handles writing that updated `tableData` to the provided external
    /// data handle `handle`.
    /// Subclasses should override `prepareToWrite()` and `write()` rather than override this method.
    /// The only exception is the `head`/`bhed` table which must do so to leave the
    /// `checksumAdjustment` field blank.
    func write(to handle: DataHandle, updating entry: OTFsfntDirectoryEntry) throws {
        dataHandle = DataHandle()
        try prepareToWrite()
        try write()
        tableData = dataHandle.data
        dataHandle = nil
        let before: UInt32 = UInt32(handle.currentOffset)
        handle.writeData(tableData)
        let after: UInt32 = UInt32(handle.currentOffset)
        let padBytesLength = (~(after & 0x3) &+ 1) & 0x3
        if padBytesLength > 0 { handle.writeData(Data(count: Int(padBytesLength))) }
        entry.tableTag = tableTag
        entry.table = self
        entry.offset = before
        entry.length = after - before
    }

    public static func `class`(for tableTag: TableTag) -> FontTable.Type {
        if tableTag == .OS_2 { return FontTable_OS2.self }
        if tableTag == .cvt_ { return FontTable_cvt.self }
        // if tableTag == .CID_ { return FontTable_CID.self }
        // if tableTag == .CFF_ { return FontTable_CFF.self }
        if let theClass: FontTable.Type = NSClassFromString("CoreFont.FontTable_\(tableTag.fourCharString)") as? FontTable.Type {
            return theClass
            /// if class is `Nil`, try byte-swapping the table tag to see if it's wrong in the font
            /// (i.e. `SOPG` instead of `GPOS`; Yes, I've seen this happen).
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
    public var hmtxTable: FontTable_hmtx? { table(for: .hmtx) as? FontTable_hmtx }
    public var os2Table:  FontTable_OS2?  { table(for: .OS_2) as? FontTable_OS2 }
    public var gaspTable: FontTable_gasp? { table(for: .gasp) as? FontTable_gasp }
    public var cvtTable:  FontTable_cvt?  { table(for: .cvt_) as? FontTable_cvt  }
    public var cmapTable: FontTable_cmap? { table(for: .cmap) as? FontTable_cmap }
    public var vheaTable: FontTable_vhea? { table(for: .vhea) as? FontTable_vhea }
    public var vmtxTable: FontTable_vmtx? { table(for: .vmtx) as? FontTable_vmtx }
    public var featTable: FontTable_feat? { table(for: .feat) as? FontTable_feat }
    public var bhedTable: FontTable_bhed? { table(for: .bhed) as? FontTable_bhed }
    public var locaTable: FontTable_loca? { table(for: .loca) as? FontTable_loca }
    public var glyfTable: FontTable_glyf? { table(for: .glyf) as? FontTable_glyf }
    public var blocTable: FontTable_bloc? { table(for: .bloc) as? FontTable_bloc }
    public var bdatTable: FontTable_bdat? { table(for: .bdat) as? FontTable_bdat }
    public var EBLCTable: FontTable_EBLC? { table(for: .EBLC) as? FontTable_EBLC }
    public var EBDTTable: FontTable_EBDT? { table(for: .EBDT) as? FontTable_EBDT }

    /// While these may seem redundant/trivial, this is adapted from code
    /// where font files (.ttc, .otc, etc.) can contain multiple fonts,
    /// and where font tables can be shared among several fonts...
    public var fontNumGlyphs: Int {
        return fontFile.numGlyphs
    }

    public func fontGlyphName<T: FixedWidthInteger>(for glyphID: T) -> String? {
        return fontFile.glyphName(for: glyphID)
    }
}

extension FontTable {

    static func OTFWritingOrderSort(lhs: FontTable, rhs: FontTable) -> Bool {
        let a = ttfWriteOrder[lhs.tableTag] ?? Int.max
        let b = ttfWriteOrder[rhs.tableTag] ?? Int.max
        if a != b { return a < b }
        return lhs.tableTag < rhs.tableTag
    }

    static let ttfWriteOrder: [TableTag: Int] = [
        .head: 1,
        .hhea: 2,
        .maxp: 3,
        .OS_2: 4,
        .hmtx: 5,
        .LTSH: 6,
        .VDMX: 7,
        .hdmx: 8,
        .cmap: 9,
        .fpgm: 10,
        .prep: 11,
        .cvt_: 12,
        .loca: 13,
        .glyf: 14,
        .kern: 15,
        .name: 16,
        .post: 17,
        .gasp: 18,
        .vhea: 19,
        .vmtx: 20,
        .PCLT: 21,
        .DSIG: 22,
    ]
}

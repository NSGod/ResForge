//
//  OTFFontFile.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport
import OrderedCollections

public struct FontWritingOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    public static let none: FontWritingOptions = []
}

final public class OTFFontFile: NSObject {
    @objc public var directory:     OTFsfntDirectory!

    public var tables:              OrderedSet<FontTable>

    private var data:               Data
    private let reader:             BinaryDataReader
    private var dataHandle:         DataHandle!

    private var tableTagsToTables:  [TableTag: FontTable] = [:]
    // this is to help determine table indexes for display in UI:
    private var rangesToFontTables: [Range<UInt32>: FontTable] = [:]

    public init(_ data: Data) throws {
        self.data = data
        reader = BinaryDataReader(data)
        tables = OrderedSet()
        super.init()
        directory = try OTFsfntDirectory(reader, fontFile: self)
        var entries = directory.entries
        entries.sort {
            // load/font tables in a specified order, since parsing some rely on presence of others
            return OTFsfntDirectoryEntry.sortForParsing(lhs: $0, rhs: $1)
        }
        for entry in entries {
            let range = entry.range
            let tableData = try reader.subdata(with: range)
            let tableClass: FontTable.Type = FontTable.class(for: entry.tableTag).self
            let table = try tableClass.init(with: tableData, tableTag: entry.tableTag, fontFile: self)
            tables.append(table)
            rangesToFontTables[range] = table
            entry.table = table
            tableTagsToTables[entry.tableTag] = table
        }
        // sort tables into the order they're found in the font for display
        tables.sort { table1, table2 in
            var offset1: UInt32 = 0
            var offset2: UInt32 = 0
            for (range, table) in rangesToFontTables {
                if table == table1 {
                    offset1 = range.lowerBound
                } else if table == table2 {
                    offset2 = range.lowerBound
                }
                if offset1 > 0 && offset2 > 0 { break }
            }
            // allow corrupt font to succeed w/o crashing
            // assert(offset1 != 0 && offset2 != 0)
            return offset1 < offset2
        }
    }

	public func data(with options: FontWritingOptions = .none) throws -> Data {
        dataHandle = DataHandle()
        // entries must be sorted by table tag
        directory.sortEntries()
        // sort tables into optimized loading order
        sortTables()
        // write the tables first
        dataHandle.seek(to: directory.totalNodeLength)
        for table in tables {
            guard let entry = directory.entry(for: table.tableTag) else { continue }
            try table.write(to: dataHandle, updating: entry)
        }

        // process and write directory and directory entries
        var checksumOffset: UInt32 = 0
        for entry in directory.entries {
            // fill in dir entry checksums
            if entry.tableTag == .head {
                checksumOffset = entry.offset + FontTable_head.checksumAdjustmentOffset
            }
            entry.checksum = entry.table.calculatedChecksum
        }
        dataHandle.seek(to: 0)
        try directory.write(to: dataHandle)
        var checksum = directory.calculatedChecksum(with: dataHandle)
        // add in the table checksums
        directory.entries.forEach({ checksum &+= $0.checksum })
        // write 'head' table checksum adjustment
        dataHandle.seek(to: checksumOffset)
        let finalChecksum: UInt32 = FontTable_head.checksumConstant - checksum
        dataHandle.write(finalChecksum)
        data = dataHandle.data
        dataHandle = nil
        return data
    }

    private func sortTables() {
        NSLog("\(type(of: self)).\(#function) tables (BEFORE) == \(tables.map(\.tableTag.fourCharString))")
        tables.sort(by: FontTable.OTFWritingOrderSort)
        NSLog("\(type(of: self)).\(#function) tables (AFTER) == \(tables.map(\.tableTag.fourCharString))")
    }

    public var numGlyphs: Int {
        if glyphLookupType == .undetermined { self .initGlyphNameLookup() }
        // FIXME: !! allow for other methods to get glyph count (see /afdko/c/spot/source/global.c for more info)
        if glyphLookupType == .post || glyphLookupType == .cmap {
            return Int(maxpTable?.numGlyphs ?? 0)
        } else if glyphLookupType == .CFF {
            // return CFFTable.numGlyphs
            return 0
        } else if glyphLookupType == .TYP1 {
            return 0
        } else if glyphLookupType == .CID {
            return 0
        }
        return Int(maxpTable?.numGlyphs ?? 0)
    }

    public func glyphName(for glyphID: Glyph32ID) -> String {
        // FIXME: !! deal with other methods of getting glyph names
        if glyphLookupType == .undetermined { self .initGlyphNameLookup() }
        var glyphName = ""
        if glyphLookupType == .post {
            glyphName = postTable?.glyphName(for: glyphID) ?? ""
        } else if glyphLookupType == .cmap {

        } else if glyphLookupType == .CFF {

        } else if glyphLookupType == .AGL {

        }
        return glyphName.isEmpty ? "<\(glyphID)" : glyphName
    }

    public var headTable: FontTable_head? {
        return table(for: .head) as? FontTable_head
    }
    public var maxpTable: FontTable_maxp? {
        return table(for: .maxp) as? FontTable_maxp
    }
    public var postTable: FontTable_post? {
        return table(for: .post) as? FontTable_post
    }
    public var nameTable: FontTable_name? {
        return table(for: .name) as? FontTable_name
    }
    public var hheaTable: FontTable_hhea? {
        return table(for: .hhea) as? FontTable_hhea
    }
    public var hmtxTable: FontTable_hmtx? {
        return table(for: .hmtx) as? FontTable_hmtx
    }
    public var os2Table: FontTable_OS2? {
        return table(for: .OS_2) as? FontTable_OS2
    }
    public var gaspTable: FontTable_gasp? {
        return table(for: .gasp) as? FontTable_gasp
    }
    public func table(for tableTag: TableTag) -> FontTable? {
        return tableTagsToTables[tableTag]
    }

    private var glyphLookupType: GlyphNameLookupType = .undetermined
    private func initGlyphNameLookup() {
        if glyphLookupType != .undetermined { return }
        if tableTagsToTables[.CFF_] != nil {
            glyphLookupType = .CFF
        } else if let postTable, postTable.version != .version3_0 {
            glyphLookupType = .post
//        } else if tableTagsToTables[.cmap] != nil && other stuff {
//          glyphLookupType = .CID
        } else if tableTagsToTables[.TYP1] != nil {
            glyphLookupType = .TYP1
        } else if tableTagsToTables[.CID_] != nil {
            glyphLookupType = .CID
        } else {
            glyphLookupType = .AGL
        }
    }

    private enum GlyphNameLookupType {
        case undetermined
        case post
        case cmap
        case CFF
        case TYP1
        case CID
        case AGL
    }
}

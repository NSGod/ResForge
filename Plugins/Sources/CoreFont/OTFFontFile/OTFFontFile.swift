//
//  OTFFontFile.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport
import OrderedCollections

public enum FontFileError: LocalizedError {
    case invalidRange(TableTag)

    public var errorDescription: String? {
        switch self {
            case .invalidRange(let tag):
                return NSLocalizedString("Invalid range for table with tag \(tag.description)", comment: "")
        }
    }
}

public struct FontWritingOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    public static let none: FontWritingOptions = []
}

public final class OTFFontFile: NSObject, UIGlyphsProvider, UIMetricsProvider {

    @objc dynamic public var directory: OTFsfntDirectory!

    public var tables:                  OrderedSet<FontTable>

    public lazy var glyphs:             [UIGlyph] = {
        buildGlyphsIfNeeded()
        return _glyphs
    }()

    public lazy var metrics:            UIFontMetrics = {
        return Metrics(fontFile: self)
    }()

    public lazy var notDef:             UIGlyph = {
        buildGlyphsIfNeeded()
        return _notDef
    }()

    private var data:                   Data
    private let reader:                 BinaryDataReader

    private var tableTagsToTables:      [TableTag: FontTable] = [:]
    // this is to help determine table indexes for display in UI:
    private var rangesToFontTables:     [Range<UInt32>: FontTable] = [:]

    private var _uvsToGlyphs:           [UV: UIGlyph] = [:]
    private var _glyphNamesToGlyphs:    [String: UIGlyph] = [:]
    private var _haveBuiltGlyphs:       Bool = false
    // private var _charCodesToGlyphs:  [CharCode32: UIGlyph] = [:]
    private var _glyphs:                [UIGlyph]!
    private var _notDef:                UIGlyph!

    public init(_ data: Data) throws {
        self.data = data
        reader = BinaryDataReader(data)
        tables = OrderedSet()
        super.init()
        directory = try OTFsfntDirectory(reader, fontFile: self)
        var entries = directory.entries
        entries.sort {
            /// load/font tables in a specified order, since parsing some
            /// rely on presence of already-parsed-state of others
            return OTFsfntDirectoryEntry.sortForParsing(lhs: $0, rhs: $1)
        }
        for entry in entries {
            let range = entry.range
            do {
                let tableData = try reader.subdata(with: range)
                let tableClass: FontTable.Type = FontTable.class(for: entry.tableTag).self
                let table = try tableClass.init(with: tableData, tableTag: entry.tableTag, fontFile: self)
                tables.append(table)
                rangesToFontTables[range] = table
                entry.table = table
                tableTagsToTables[entry.tableTag] = table
            } catch {
                // FIXME: allow lower errors to come through rather than making everything an invalid range error
                NSLog("\(type(of: self)).\(#function) error == \(error)")
                throw FontFileError.invalidRange(entry.tableTag)
            }
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
        let dataHandle = DataHandle()
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
            entry.checksum = entry.table.calculatedChecksum
            if entry.tableTag == .head {
                checksumOffset = entry.offset + FontTable_head.checksumAdjustmentOffset
            }
        }
        dataHandle.seek(to: 0)
        try directory.write(to: dataHandle)
        var checksum = directory.calculatedChecksum(with: dataHandle)
        // add in the table checksums
        directory.entries.forEach { checksum &+= $0.checksum }
        // write 'head' table checksum adjustment
        dataHandle.seek(to: checksumOffset)
        let finalChecksum: UInt32 = FontTable_head.checksumConstant &- checksum
        dataHandle.write(finalChecksum)
        data = dataHandle.data
        return data
    }

    private func sortTables() {
        tables.sort(by: FontTable.OTFWritingOrderSort)
    }

    public var postScriptName: String {
        return nameTable?.postScriptName ?? NSLocalizedString("<Unknown>", comment: "")
    }
    
    public var numGlyphs: Int {
        if glyphLookupType == .undetermined { initGlyphNameLookup() }
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

    public func glyphName<T: FixedWidthInteger>(for glyphID: T) -> String {
        // FIXME: !! deal with other methods of getting glyph names
        if glyphLookupType == .undetermined { initGlyphNameLookup() }
        var glyphName = ""
        if glyphLookupType == .post {
            glyphName = postTable?.glyphName(for: glyphID) ?? ""
        } else if glyphLookupType == .cmap {

        } else if glyphLookupType == .CFF {

        } else if glyphLookupType == .AGL {

        }
        return glyphName.isEmpty ? "<\(glyphID)>" : glyphName
    }

    public func glyph(for uv: UVBMP) -> UIGlyph {
        buildGlyphsIfNeeded()
        return _uvsToGlyphs[UV(uv)] ?? notDef
    }

    public func glyph(forName name: String) -> UIGlyph {
        buildGlyphsIfNeeded()
        return _glyphNamesToGlyphs[name] ?? notDef
    }

    public func glyph<T: FixedWidthInteger>(for glyphID: T) -> UIGlyph? {
        buildGlyphsIfNeeded()
        if glyphID > glyphs.count {
            NSLog("\(type(of: self)).\(#function) *** INVALID glyphID: \(glyphID) > count: \(glyphs.count)")
            // FIXME: or should this return .notdef glyph?
            return nil
        }
        return glyphs[Int(glyphID)]
    }

    private var glyphLookupType: GlyphNameLookupType = .undetermined

    private func initGlyphNameLookup() {
        if glyphLookupType != .undetermined { return }
        if tableTagsToTables[.CFF_] != nil {
            glyphLookupType = .CFF
        } else if let postTable, postTable.version != .version3_0 {
            glyphLookupType = .post
        // } else if tableTagsToTables[.cmap] != nil && some other stuff {
        // glyphLookupType = .CID
        } else if tableTagsToTables[.TYP1] != nil {
            glyphLookupType = .TYP1
        } else if tableTagsToTables[.CID_] != nil {
            glyphLookupType = .CID
        } else {
            glyphLookupType = .AGL
        }
    }

    private func buildGlyphsIfNeeded() {
        initGlyphNameLookup()
        if _haveBuiltGlyphs { return }
        NSLog("\(type(of: self)).\(#function) building glyphs....")
        guard let charCodesToGlyphIDs = cmapTable?.preferredEncoding.subtable.charCodesToGlyphIDs else {
            NSLog("\(type(of: self)).\(#function) *** NO preferred encoding could be found in cmap table!")
            return
        }
        if let glyphs = glyfTable?.glyphs as? [any UIGlyph] {
            _glyphs = glyphs
        } else {
            _glyphs = []
        }
        // FIXME: this should be mapping UVs to glyphs, not char codes to glyphs?
        let glyphCount = _glyphs.count
        let charCodes = charCodesToGlyphIDs.keys.sorted()
        for charCode in charCodes {
            let glyphID = charCodesToGlyphIDs[charCode]!
            if glyphID >= glyphCount { continue }
            var glyph = _glyphs[Int(glyphID)]
            _uvsToGlyphs[charCode] = glyph
            if glyph.uv == .undefined {
                glyph.uv = charCode
            } else {
                if glyph.additionalUVs == nil { glyph.additionalUVs = [] }
                glyph.additionalUVs?.insert(Int(charCode))
            }
        }
        var i = 0
        for var glyph in _glyphs {
            if glyphLookupType == .AGL {
                if glyph.uv != .undefined {
                    if let glyphName = AdobeGlyphList.glyphName(for: UVBMP(glyph.uv)) {
                        glyph.glyphName = glyphName
                    } else {
                        // FIXME: !! improve this method according to guidelines in AGL/AGLFN?
                        if glyph.uv <= UVBMP.undefined {
                            glyph.glyphName = String(format: "uni%04hX", UVBMP(glyph.uv))
                        } else {
                            glyph.glyphName = String(format: "u%06X", glyph.uv)
                        }
                    }
                } else if glyph.uv == .undefined && i == 0 {
                    glyph.glyphName = ".notdef"
                } else {
                    glyph.glyphName = "_\(glyph.glyphID)"
                }
            }
            _glyphNamesToGlyphs[glyph.glyphName] = glyph
            i += 1
        }
        _haveBuiltGlyphs = true
        _notDef = _glyphNamesToGlyphs[".notdef"] ?? _glyphs.first!
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
    public var cvtTable: FontTable_cvt? {
        return table(for: .cvt_ ) as? FontTable_cvt
    }
    public var cmapTable: FontTable_cmap? {
        return table(for: .cmap) as? FontTable_cmap
    }
    public var vheaTable: FontTable_vhea? {
        return table(for: .vhea) as? FontTable_vhea
    }
    public var vmtxTable: FontTable_vmtx? {
        return table(for: .vmtx) as? FontTable_vmtx
    }
    public var featTable: FontTable_feat? {
        return table(for: .feat) as? FontTable_feat
    }
    public var bhedTable: FontTable_bhed? {
        return table(for: .bhed) as? FontTable_bhed
    }
    public var locaTable: FontTable_loca? {
        return table(for: .loca) as? FontTable_loca
    }
    public var glyfTable: FontTable_glyf? {
        return table(for: .glyf) as? FontTable_glyf
    }
    public var blocTable: FontTable_bloc? {
        return table(for: .bloc) as? FontTable_bloc
    }
    public var bdatTable: FontTable_bdat? {
        return table(for: .bdat) as? FontTable_bdat
    }
    public var EBLCTable: FontTable_EBLC? {
        return table(for: .EBLC) as? FontTable_EBLC
    }
    public var EBDTTable: FontTable_EBDT? {
        return table(for: .EBDT) as? FontTable_EBDT
    }
    public func table(for tableTag: TableTag) -> FontTable? {
        return tableTagsToTables[tableTag]
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

//
//  FontTable_loca.swift
//  CoreFont
//
//  Created by Mark Douma on 3/21/2026.
//

import Cocoa
import RFSupport

/// `REQUIRES`: `head`, `maxp`
/// `DEPENDS ON`:
/// `DISPLAY DEPENDS ON`: `post`

public final class FontTable_loca: FontTable {

    // FIXME: figure out a better way of doing UInt32/UInt16?
    public var offsets:                      [UInt32] = []  // UInt32 or UInt16, depending on format

    // MARK: AUX for display
    @objc dynamic public var glyphLocations: [GlyphLocation] = []

    public required init(with tableData: Data, tableTag: TableTag, fontFile: OTFFontFile) throws {
        try super.init(with: tableData, tableTag: tableTag, fontFile: fontFile)
        let numGlyphs = fontFile.numGlyphs
        guard let format = headTable?.indexToLocFormat else {
            throw FontTableError.parseError("loca table: unable to get headTable.indexToLocFormat")
        }
        if format == .short {
            offsets = try (0..<numGlyphs + 1).map { _ in
                let offset: UInt16 = try reader.read()
                return UInt32(offset)
            }
        } else {
            offsets = try (0..<numGlyphs + 1).map { _ in try reader.read() }
        }
        rebuildGlyphLocations(using: format)
    }

//    override func prepareToWrite() throws {
//        /// convert to `.short` format if possible?
//        var allEven = true
//        var maxLocation: UInt32 = 0
//        for loc in offsets {
//            maxLocation = max(maxLocation, loc)
//            if loc % 2 != 0 { allEven = false }
//        }
//        if maxLocation < 0x20000 && allEven {
//            // reduce to shorts
//        }
//    }

    override func write() throws {
        guard let format = headTable?.indexToLocFormat else {
            throw FontTableError.writeError("loca table: unable to get headTable.indexToLocFormat")
        }
        offsets.forEach { format == .short ? dataHandle.write(UInt16($0)) : dataHandle.write($0) }
    }

    private func rebuildGlyphLocations(using format: LocaOffsetFormat) {
        var glyphLocations: [GlyphLocation] = []
        for (glyphID, offset) in offsets.enumerated() {
            let glyphLocation = GlyphLocation(glyphID: GlyphID(glyphID), offset: (format == .short ? offset * 2 :  offset), table: self)
            glyphLocations.append(glyphLocation)
        }
        var count = glyphLocations.count
        if count > 0 { count -= 1 }
        for i in 0..<count {
            let loc = glyphLocations[i]
            let nextLoc = glyphLocations[i + 1]
            loc.length = nextLoc.offset - loc.offset
        }
        if count > 0 { glyphLocations.removeLast() }
        self.glyphLocations = glyphLocations
    }
}

extension FontTable_loca {

    // MARK: AUX class for display
    public final class GlyphLocation: FontTableNode {
        /// these values are already pre-multiplied to represent actual byte offsets
        @objc dynamic public var offset:        UInt32
        @objc dynamic public var length:        UInt32 = 0  // set by FontTable_loca

        @objc public var glyphID:               GlyphID
        @objc public lazy var glyphName:        String = {
            return table.fontGlyphName(for: glyphID) ?? "<\(glyphID)>"
        }()

        /// offset values should be premultiplied to represent byte lengths
        public init(glyphID: GlyphID, offset: UInt32, table: FontTable) {
            self.glyphID = glyphID
            self.offset  = offset
            try! super.init(table: table)
        }
    }
}

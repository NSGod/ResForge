//
//  Format4_0.swift
//  CoreFont
//
//  Created by Mark Douma on 1/21/2026.
//

import Foundation
import RFSupport

public extension FontTable_post {

    final class Format4_0: Format {
        var codes:                  [UInt16] = []

        required public init(_ reader: BinaryDataReader, offset: Int? = nil, table: FontTable? = nil) throws {
            #warning("not yet implemented, need fontNumGlyphs from maxpTable.numGlyphs")
            try super.init(reader)
        }
    }

}

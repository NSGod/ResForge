//
//  UnicodePointFormatter.swift
//  FontEditor
//
//  Created by Mark Douma on 1/29/2026.
//

import Foundation

class UnicodePointFormatter: NumberFormatter, @unchecked Sendable {

    override func string(for obj: Any?) -> String? {
        guard let value: UInt32 = obj as? UInt32 else { return nil }
        return String(format: "U+%04X", value)
    }

}

//
//  CharFormatter.swift
//  Plugins
//
//  Created by Mark Douma on 1/6/2026.
//

import Cocoa

class CharFormatter: NumberFormatter, @unchecked Sendable {

    override func string(for obj: Any?) -> String? {
        guard let asciicode = obj as? UInt8 else {
            return nil
        }
        let string = String(bytes: [asciicode], encoding: .macOSRoman)
        return string
    }
}

//
//  CharFormatter.swift
//  CoreFont
//
//  Created by Mark Douma on 1/6/2026.
//

import Foundation

final public class CharFormatter: NumberFormatter, @unchecked Sendable {

    public override func string(for obj: Any?) -> String? {
        guard let asciicode = obj as? UInt8 else {
            return nil
        }
        let string = String(bytes: [asciicode], encoding: .macOSRoman)
        return string
    }
}

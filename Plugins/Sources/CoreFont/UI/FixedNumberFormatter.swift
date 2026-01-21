//
//  FixedNumberFormatter.swift
//  CoreFont
//
//  Created by Mark Douma on 1/19/2026.
//

import Foundation

class FixedNumberFormatter: NumberFormatter, @unchecked Sendable {

    override func string(for obj: Any?) -> String? {
        guard let obj = (obj as? NSNumber)?.int32Value else { return nil }
        return super.string(for: FixedToFloat(obj))
    }
}

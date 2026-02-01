//
//  GreaterThanZeroTransformer.swift
//  Plugins
//
//  Created by Mark Douma on 2/1/2026.
//

import Foundation

extension NSValueTransformerName {
    static let isNotZero = NSValueTransformerName("GreaterThanZeroTransformer")
}

final class GreaterThanZeroTransformer: ValueTransformer {

    override func transformedValue(_ value: Any?) -> Any? {
        if let value = value as? Int, value > 0 {
            return true
        }
        return false
    }
}

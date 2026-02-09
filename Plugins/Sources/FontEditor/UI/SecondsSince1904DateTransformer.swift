//
//  SecondsSince1904DateTransformer.swift
//  FontEditor
//
//  Created by Mark Douma on 2/8/2026.
//

import Foundation
import CoreFont

final class SecondsSince1904DateTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSDate.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? Int64 else { return nil }
        return Date(secondsSince1904: value)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let value = value as? Date else { return nil }
        return value.secondsSince1904
    }
}

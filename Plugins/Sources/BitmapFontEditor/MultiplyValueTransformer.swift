//
//  MultiplyValueTransformer.swift
//  BitmapFontEditor
//
//  Created by Mark Douma on 2/13/2026.
//

import Cocoa

class MultiplyValueTransformer: ValueTransformer {

    @IBInspectable var multiplier: Int = 16

    override class func transformedValueClass() -> AnyClass {
        return NSNumber.self
    }

    override class func allowsReverseTransformation() -> Bool { false }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let intValue = value as? Int else { return nil }
        return intValue * multiplier
    }
}

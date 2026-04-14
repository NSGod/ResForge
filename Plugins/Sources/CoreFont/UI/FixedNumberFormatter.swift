//
//  FixedNumberFormatter.swift
//  CoreFont
//
//  Created by Mark Douma on 1/19/2026.
//

import Foundation

public final class FixedNumberFormatter: NumberFormatter, @unchecked Sendable {

    public override func string(for obj: Any?) -> String? {
        guard let obj = (obj as? NSNumber)?.int32Value else { return nil }
        return super.string(for: FixedToFloat(obj))
    }

    public override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        guard let obj else { return false }
        var value: AnyObject? = nil
        if super.getObjectValue(&value, for: string, errorDescription: error) {
            if let value, let value = value as? NSNumber {
                let int32Value = FloatToFixed(value.floatValue)
                obj.pointee = NSNumber(value: int32Value) as AnyObject
                return true
            }
        }
        return false
    }
}

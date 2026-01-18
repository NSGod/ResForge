//
//  Fixed4Dot12NumberFormatter.swift
//  CoreFont
//
//  Created by Mark Douma on 12/29/2025.
//

import Foundation

final public class Fixed4Dot12NumberFormatter: NumberFormatter, @unchecked Sendable {

    public override func string(for obj: Any?) -> String? {
//        NSLog("\(type(of: self)).\(#function)() obj == \(obj.debugDescription)")
        guard let numValue = (obj as? NSNumber)?.int16Value else {
            return nil
        }
        return super.string(for: Fixed4Dot12ToDouble(numValue))
    }

    public override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        let result = super.getObjectValue(obj, for: string, errorDescription: error)
        if result, let doubleValue = obj?.pointee as? Double {
            obj?.pointee = NSNumber(value: Fixed4Dot12(DoubleToFixed4Dot12(doubleValue))) as AnyObject
        }
        return result
    }

}

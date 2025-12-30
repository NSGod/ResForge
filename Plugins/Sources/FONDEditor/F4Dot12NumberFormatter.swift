//
//  F4Dot12NumberFormatter.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/29/2025.
//

import Cocoa

class F4Dot12NumberFormatter: NumberFormatter, @unchecked Sendable {

    public override func string(for obj: Any?) -> String? {
        NSLog("\(type(of: self)).\(#function)() obj == \(obj.debugDescription)")

//        guard type(of: obj) == String.self else {
//            return nil
//        }
        guard let numValue = (obj as? NSNumber)?.int16Value else {
            return nil
        }
        let doubleValue: Double = Fixed4Dot12ToDouble(numValue)
        return super.string(for: doubleValue)
    }

//    public override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
//
//    }

}

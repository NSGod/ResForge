//
//  HexNumberFormatter.swift
//  CoreFont
//
//  Created by Mark Douma on 1/6/2026.
//

import Foundation

public final class HexNumberFormatter: NumberFormatter, @unchecked Sendable {

    @IBInspectable public var leadingZeroes: Bool = false

    /// - Important: You must set a `maximum` value (either `UInt64.max`,
    ///  `UInt32.max`, `UInt16.max`, or `UInt8.max`) for the number formatter in IB
    ///   or programmatically *before* ``string(for:)`` is called.

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func string(for obj: Any?) -> String? {
        guard let numberValue = obj as? UInt64 else { return nil }
        guard let maxValue = self.maximum?.uint64Value else {
            fatalError("you must set a max value")
        }
        assert(maxValue == UInt64.max || maxValue == UInt32.max || maxValue == UInt16.max || maxValue == UInt8.max)
        if maxValue == UInt64.max {
            return String(format: (leadingZeroes ? "0x%016llX" : "0x%02llX"), numberValue)
        } else if maxValue == UInt32.max {
            let numValue = UInt32(truncatingIfNeeded: numberValue)
            return String(format: (leadingZeroes ? "0x%08X" : "0x%02X"), numValue)
        } else if maxValue == UInt16.max {
            let numValue = UInt16(truncatingIfNeeded: numberValue)
            return String(format: (leadingZeroes ? "0x%04hX" : "0x%02hX"), numValue)
        } else if maxValue == UInt8.max {
            let numValue = UInt8(truncatingIfNeeded: numberValue)
            return String(format: "0x%02hhX", numValue)
        }
        return nil
    }

    public override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        guard let maxValue = self.maximum?.uint64Value else {
            fatalError("you must set a max value")
        }
        assert(maxValue == UInt64.max || maxValue == UInt32.max || maxValue == UInt16.max || maxValue == UInt8.max)
        guard let obj else { return false }
        let scanner = Scanner(string: string)
        if let value = scanner.scanUInt64(representation: .hexadecimal) {
            if maxValue == UInt32.max {
                obj.pointee = UInt32(truncatingIfNeeded: value) as AnyObject
            } else if maxValue == UInt16.max {
                obj.pointee = UInt16(truncatingIfNeeded: value) as AnyObject
            } else if maxValue == UInt8.max {
                obj.pointee = UInt8(truncatingIfNeeded: value) as AnyObject
            }
            obj.pointee = value as AnyObject
            return true
        } else {
            if let error = error {
                error.pointee = NSLocalizedString("Not a hex number.", comment: "") as NSString
            }
        }
        return false
    }
}

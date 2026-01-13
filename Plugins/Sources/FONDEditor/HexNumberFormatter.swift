//
//  HexNumberFormatter.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/6/2026.
//

import Foundation

class HexNumberFormatter: NumberFormatter, @unchecked Sendable {

    override func string(for obj: Any?) -> String? {
        guard let numberValue = obj as? UInt32 else { return nil }
        let maxValue = self.maximum?.uint32Value ?? 0
        if maxValue == UInt32.max {
            return String(format: "0x%08x", numberValue)
        } else if maxValue == UInt16.max {
            return String(format: "0x%04x", UInt16(numberValue))
        } else if maxValue == UInt8.max {
            return String(format: "0x%02x", UInt8(numberValue))
        }
        return nil
    }

    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        guard let obj else { return false }
        let scanner = Scanner(string: string)
        if let value = scanner.scanInt(representation: .hexadecimal) {
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

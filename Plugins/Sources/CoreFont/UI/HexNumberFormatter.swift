//
//  HexNumberFormatter.swift
//  CoreFont
//
//  Created by Mark Douma on 1/6/2026.
//

import Foundation

public class HexNumberFormatter: NumberFormatter, @unchecked Sendable {
    @IBInspectable @objc var maxValue: NSNumber?

    public override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
    }

    public override func string(for obj: Any?) -> String? {
        guard let numberValue = obj as? UInt64 else { return nil }
        guard let maxValue = self.maximum?.uint64Value else {
            fatalError("you must set a max value")
        }
        if maxValue == UInt64.max {
            return String(format: "0x%016llX", numberValue)
        } else if maxValue == UInt32.max {
            let numValue = UInt32(truncatingIfNeeded: numberValue)
            return String(format: "0x%08X", numValue)
        } else if maxValue == UInt16.max {
            let numValue = UInt16(truncatingIfNeeded: numberValue)
            return String(format: "0x%04hX", numValue)
        } else if maxValue == UInt8.max {
            let numValue = UInt8(truncatingIfNeeded: numberValue)
            return String(format: "0x%02hhX", numValue)
        }
        return nil
    }

    public override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        guard let obj else { return false }
        let scanner = Scanner(string: string)
        if let value = scanner.scanUInt64(representation: .hexadecimal) {
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

//
//  OSTypeFormatter.swift
//  CoreFont
//
//  Created by Mark Douma on 1/12/2026.
//

import Cocoa
import RFSupport

class OSTypeFormatter: Formatter {

    static let attrs = [NSAttributedString.Key.font: NSFont.monospacedDigitSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)]

    override func string(for obj: Any?) -> String? {
        if let osType = obj as? Tag {
            return osType.fourCharString
        }
        return nil
    }

    override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedString.Key : Any]? = nil) -> NSAttributedString? {
        if let osType = obj as? Tag {
            return NSAttributedString(string: osType.fourCharString, attributes: Self.attrs)
        }
        return nil
    }

    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        guard let obj else { return false }
        let string = string
        obj.pointee = Tag(fourCharString: string) as AnyObject
        return true
    }
}

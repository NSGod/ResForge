//
//  FEListFormatter.swift
//  FontEditor
//
//  Created by Mark Douma on 4/21/2026.
//

import Foundation

public final class FEListFormatter: ListFormatter {

    public override init() {
        // NSLog("\(type(of: self)).\(#function)")
        super.init()
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .decimal
        numFormatter.minimum = 0
        numFormatter.maximum = 512
        itemFormatter = numFormatter
    }

    public required init?(coder: NSCoder) {
        // NSLog("\(type(of: self)).\(#function)")
        super.init(coder: coder)
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .decimal
        numFormatter.minimum = 0
        numFormatter.maximum = 512
        itemFormatter = numFormatter
    }

    public override func string(for obj: Any?) -> String? {
        guard let sizes = obj as? [Int] else { return nil }
        let separator = locale.groupingSeparator ?? NSLocalizedString(",", comment: "")
        return sizes.compactMap { itemFormatter?.string(for: $0) }.joined(separator: separator + NSLocalizedString(" ", comment: ""))
    }

    public override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        guard let itemFormatter else { return false }
        let separator = locale.groupingSeparator ?? NSLocalizedString(",", comment: "")
        let items = (string as NSString).components(separatedBy: separator)
        let values: [Int] = items.compactMap { (itemFormatter as! NumberFormatter).number(from: $0) as? Int }
        if let obj {
            obj.pointee = values as AnyObject
            return true
        }
        return false
    }
}

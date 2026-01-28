//
//  Fixed4Dot12ToEmValueFormatter.swift
//  CoreFont
//
//  Created by Mark Douma on 1/6/2026.
//

import Foundation

final public class Fixed4Dot12ToEmValueFormatter: NumberFormatter, @unchecked Sendable {

    public var unitsPerEm: UnitsPerEm  = .custom(0)

    public override func copy() -> Any {
        let result: Fixed4Dot12ToEmValueFormatter = super.copy() as! Fixed4Dot12ToEmValueFormatter
        result.unitsPerEm = unitsPerEm
        return result
    }

    public override func string(for obj: Any?) -> String? {
        guard let obj, let value = obj as? Fixed4Dot12 else { return nil }
        return super.string(for: Fixed4Dot12ToDouble(value) * Double(unitsPerEm.rawValue))
    }
}

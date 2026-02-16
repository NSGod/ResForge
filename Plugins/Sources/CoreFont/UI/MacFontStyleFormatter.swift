//
//  MacFontStyleFormatter.swift
//  CoreFont
//
//  Created by Mark Douma on 1/5/2026.
//

import Foundation

final public class MacFontStyleFormatter: NumberFormatter, @unchecked Sendable {

    public override func string(for obj: Any?) -> String? {
        guard let style = obj as? MacFontStyle.RawValue else { return nil }
        return MacFontStyle(rawValue: style).description
    }
}

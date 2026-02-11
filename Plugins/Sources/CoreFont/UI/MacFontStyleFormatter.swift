//
//  MacFontStyleFormatter.swift
//  CoreFont
//
//  Created by Mark Douma on 1/5/2026.
//

import Foundation

final class MacFontStyleFormatter: NumberFormatter, @unchecked Sendable {

    override func string(for obj: Any?) -> String? {
        guard let style = obj as? MacFontStyle.RawValue else { return nil }
        return MacFontStyle(rawValue: style).description
    }
}

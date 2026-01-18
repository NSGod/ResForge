//
//  NFNTTextStorage.swift
//  BitmapFontEditor
//
//  Created by Mark Douma on 1/14/2026.
//

import Cocoa
import RFSupport

/// This typesetting architecture is loosely modeled after Cocoa's older
/// style. At the top is `NFNTTextStorage`, which is a model for the string,
/// and owns all the other objects. `NFNTLayoutManager` uses `NFNTTextContainer`
/// to model the area in which to set the type. It uses `NFNTTypesetter` to
/// generate an array of `NFNTLineFragment`s, which are themselves an array
/// of `NFNT,Glyph`s. The layout manager then does the drawing.
///
///     `NFNTTextStorage`
///                |
///             `NFNTLayoutManager`
///               |      |       |
/// `NFNTTextContainer`  |   `NFNTTypesetter`
///                      |       |
///              `[NFNTLineFragment]`
///                      |
///                `[NFNT.Glyph]`

class NFNTTextStorage {
    var string:         String! {
        didSet {
            guard let layoutManager else { return }
            layoutManager.stringDidChange()
        }
    }

    var alignment:      NSTextAlignment = .left {
        didSet {
            guard let layoutManager else { return }
            layoutManager.alignmentDidChange()
        }
    }

    var nfnt:           NFNT! {
        didSet {
            guard let layoutManager else { return }
            layoutManager.fontDidChange()
        }
    }

    var layoutManager:  NFNTLayoutManager! {
        didSet {
            layoutManager.textStorage = self
        }
    }

}

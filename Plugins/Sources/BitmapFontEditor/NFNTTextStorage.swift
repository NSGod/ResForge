//
//  NFNTTextStorage.swift
//  BitmapFontEditor
//
//  Created by Mark Douma on 1/14/2026.
//

import Cocoa
import RFSupport

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
            NSLog("\(type(of: self)).\(#function)")
            guard let layoutManager else { return }
            layoutManager.fontDidChange()
        }
    }

    var layoutManager:  NFNTLayoutManager! {
        didSet {
            layoutManager.textStorage = self
        }
    }

    init() {
        NSLog("\(type(of: self)).\(#function)")
    }

}

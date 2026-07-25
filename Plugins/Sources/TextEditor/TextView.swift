//
//  TextView.swift
//  TextEditor
//
//  Created by Mark Douma on 7/7/2026.
//

import Cocoa
import CoreFont

class TextView: NSTextView {

    required init?(coder: NSCoder) {
        NSLog("\(type(of: self)).\(#function)")
        super.init(coder: coder)
    }

    override func cut(_ sender: Any?) {
        NSLog("\(type(of: self)).\(#function)")
        super.cut(sender)
    }

    override func copy(_ sender: Any?) {
        // NSLog("\(type(of: self)).\(#function)")
        super.copy(sender)
    }

    override func paste(_ sender: Any?) {
        NSLog("\(type(of: self)).\(#function)")
        super.paste(sender)
    }

    override func pasteAsRichText(_ sender: Any?) {
        NSLog("\(type(of: self)).\(#function)")
        super.pasteAsRichText(sender)
    }

    override func pasteAsPlainText(_ sender: Any?) {
        NSLog("\(type(of: self)).\(#function)")
        super.pasteAsPlainText(sender)
    }

    override var writablePasteboardTypes: [NSPasteboard.PasteboardType] {
        return super.writablePasteboardTypes + [.RFAttributedStylString]
    }

    override func writeSelection(to pboard: NSPasteboard, type aType: NSPasteboard.PasteboardType) -> Bool {
        // NSLog("\(type(of: self)).\(#function) pboard: \(pboard), type: \(aType)")
        if aType == .RFAttributedStylString {
            do {
                let selectedRange = selectedRanges.first!.rangeValue
                guard let textStorage = layoutManager?.textStorage as? Styl.TextStorage else { return false }
                let styledStrings = try textStorage.attributedStylStrings(from: selectedRange)
                if !pboard.writeObjects(styledStrings) {
                    NSLog("\(type(of: self)).\(#function) failed to write objects to pasteboard!")
                    return false
                }
                return true
            } catch {
                NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
                return false
            }
        }
        return super.writeSelection(to: pboard, type: aType)
    }

    override func writeSelection(to pboard: NSPasteboard, types: [NSPasteboard.PasteboardType]) -> Bool {
        // NSLog("\(type(of: self)).\(#function) pboard: \(pboard), types: \(types)")
        return super.writeSelection(to: pboard, types: types)
    }

    override var readablePasteboardTypes: [NSPasteboard.PasteboardType] {
        return super.readablePasteboardTypes + [.RFAttributedStylString]
    }

    override func preferredPasteboardType(from availableTypes: [NSPasteboard.PasteboardType], restrictedToTypesFrom allowedTypes: [NSPasteboard.PasteboardType]?) -> NSPasteboard.PasteboardType? {
        // NSLog("\(type(of: self)).\(#function) availableTypes: \(availableTypes), allowedTypes: \(allowedTypes ?? [])")
        return super.preferredPasteboardType(from: availableTypes, restrictedToTypesFrom: allowedTypes)
    }

    override func readSelection(from pboard: NSPasteboard, type pboardType: NSPasteboard.PasteboardType) -> Bool {
        // NSLog("\(type(of: self)).\(#function) pboard: \(pboard), type: \(pboardType)")
        if pboardType == .RFAttributedStylString {
            do {
                guard let textStorage = layoutManager?.textStorage as? Styl.TextStorage else { return false }
                var range = selectedRange
                guard let styledStrings: [Styl.StyledString] = pboard.readObjects(forClasses: [Styl.StyledString.self]) as? [Styl.StyledString] else { return false }
                for styledString in styledStrings {
                    textStorage.replaceCharacters(in: range, with: styledString.string)
                    let length = (styledString.string as NSString).length
                    range.length = length
                    textStorage.setAttributes(styledString.style.attrs, range: range)
                    range.location += length
                    range.length = 0
                }
                return true
            }
        }
        return super.readSelection(from: pboard, type: pboardType)
    }
}

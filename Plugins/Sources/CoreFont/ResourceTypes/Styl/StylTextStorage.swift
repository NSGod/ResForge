//
//  StylTextStorage.swift
//  CoreFont
//
//  Created by Mark Douma on 6/2/2026.
//

import Cocoa
import RFSupport

public class StylTextStorage: NSTextStorage {
    private var storage = NSTextStorage()

    /// primitives:
    public override var string: String {
        return storage.string
    }

    public override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
//        NSLog("\(type(of: self)).\(#function) location == \(location)")
//        if location >= storage.length {
//            NSLog("\(type(of: self)).\(#function) location >= storage.length (\(storage.length))")
//        }
        return storage.attributes(at: location, effectiveRange: range)
    }

    public override func replaceCharacters(in range: NSRange, with str: String) {
//        NSLog("\(type(of: self)).\(#function) range: \(range)")
        storage.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)
    }

    public override func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
        NSLog("\(type(of: self)).\(#function) range: \(range)")
        storage.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
    }

    // MARK: -
    public override func attributes(at location: Int, longestEffectiveRange range: NSRangePointer?, in rangeLimit: NSRange) -> [NSAttributedString.Key : Any] {
//        NSLog("\(type(of: self)).\(#function)")
        return storage.attributes(at: location, longestEffectiveRange: range, in: rangeLimit)
    }

    public override func edited(_ editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        NSLog("\(type(of: self)).\(#function)")
        super.edited(editedMask, range: editedRange, changeInLength: delta)
    }

    public override func processEditing() {
        NSLog("\(type(of: self)).\(#function)")
        super.processEditing()
    }

    public override func addLayoutManager(_ aLayoutManager: NSLayoutManager) {
        NSLog("\(type(of: self)).\(#function) layoutManager == \(aLayoutManager)")
        super.addLayoutManager(aLayoutManager)
    }

    public override func beginEditing() {
        NSLog("\(type(of: self)).\(#function)")
        super.beginEditing()
    }

    public override func endEditing() {
        NSLog("\(type(of: self)).\(#function)")
        super.endEditing()
    }

    public override func addAttributes(_ attrs: [NSAttributedString.Key : Any] = [:], range: NSRange) {
        NSLog("\(type(of: self)).\(#function)")
        super.addAttributes(attrs, range: range)
    }

    //    public override func replaceCharacters(in range: NSRange, with attrString: NSAttributedString) {
    //        NSLog("\(type(of: self)).\(#function)")
    //        beginEditing()
    //        storage.replaceCharacters(in: range, with: attrString)
    //        edited(.editedCharacters, range: range, changeInLength: attrString.length - range.length)
    //        endEditing()
    //    }

}

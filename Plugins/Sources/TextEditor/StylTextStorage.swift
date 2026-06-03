//
//  StylTextStorage.swift
//  TextEditor
//
//  Created by Mark Douma on 6/2/2026.
//

import Cocoa
import RFSupport
import CoreFont

public class StylTextStorage: NSTextStorage {
    private var storage = NSTextStorage()

    /// primitives:
    public override var string: String {
        return storage.string
    }

    public override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return storage.attributes(at: location, effectiveRange: range)
    }

    public override func replaceCharacters(in range: NSRange, with str: String) {
        NSLog("\(type(of: self)).\(#function)")
        // beginEditing()
        storage.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)
        // endEditing()
    }

    public override func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
        NSLog("\(type(of: self)).\(#function)")
        // beginEditing()
        storage.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        // endEditing()
    }

    // MARK: -
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

//    public override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
//        NSLog("\(type(of: self)).\(#function)")
//        super.setAttributes(attrs, range: range)
//    }

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

    //    public override init(attributedString attrStr: NSAttributedString) {
    //        NSLog("\(type(of: self)).\(#function)")
    //        super.init(attributedString: attrStr)
    //    }
    //
    //    override init(string str: String, attributes attrs: [NSAttributedString.Key : Any]? = nil) {
    //        NSLog("\(type(of: self)).\(#function)")
    //        super.init(string: str, attributes: attrs)
    //    }
    //
    //    required init?(coder: NSCoder) {
    //        NSLog("\(type(of: self)).\(#function)")
    //        super.init(coder: coder)
    //        fatalError("init(coder:) has not been implemented")
    //    }
    //
    //    required init?(pasteboardPropertyList propertyList: Any, ofType pbType: NSPasteboard.PasteboardType) {
    //        NSLog("\(type(of: self)).\(#function)")
    //        super.init(pasteboardPropertyList: propertyList, ofType: pbType)
    //    }
}

//
//  Styl.TextStorage.swift
//  CoreFont
//
//  Created by Mark Douma on 6/2/2026.
//

import Cocoa
import RFSupport

extension Styl {

    public class TextStorage: NSTextStorage {
        private var storage = NSTextStorage()

        public var styleRuns: [Run] {
            var runs: [Run] = []
            let fullRange = NSMakeRange(0, length)
            storage.enumerateAttributes(in: fullRange, using: { (attrs, range, _) in
                guard let style = attrs[.stylStyle] as? Style else { return }
                let run = Run(style: style, range: range)
                if let lastRun = runs.last {
                    if lastRun.canMerge(with: run) {
                        lastRun.merge(with: run)
                    } else {
                        runs.append(run)
                    }
                } else {
                    runs.append(run)
                }
            })
            return runs
        }

        /// primitives:
        public override var string: String {
            return storage.string
        }

        public override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
            return storage.attributes(at: location, effectiveRange: range)
        }

        public override func replaceCharacters(in range: NSRange, with str: String) {
            // NSLog("\(type(of: self)).\(#function) range: \(range)")
            /// replace `\n` with `\r`:
            let mString = str.replacingOccurrences(of: "\n", with: "\r")
            storage.replaceCharacters(in: range, with: mString)
            edited(.editedCharacters, range: range, changeInLength: (mString as NSString).length - range.length)
        }

        public override func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
            // NSLog("\(type(of: self)).\(#function) range: \(range)")
            if let style = attrs?[.stylStyle] as? Styl.Style, let count = attrs?.count, count == 1 {
                storage.setAttributes(style.attrs, range: range)
            } else {
                storage.setAttributes(attrs, range: range)
            }
            edited(.editedAttributes, range: range, changeInLength: 0)
        }

        // MARK: -
        public override func attributes(at location: Int, longestEffectiveRange range: NSRangePointer?, in rangeLimit: NSRange) -> [NSAttributedString.Key : Any] {
            return storage.attributes(at: location, longestEffectiveRange: range, in: rangeLimit)
        }

        public override func edited(_ editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
            // NSLog("\(type(of: self)).\(#function)")
            super.edited(editedMask, range: editedRange, changeInLength: delta)
        }

        public override func processEditing() {
            // NSLog("\(type(of: self)).\(#function)")
            super.processEditing()
        }

        public override func addLayoutManager(_ aLayoutManager: NSLayoutManager) {
            // NSLog("\(type(of: self)).\(#function) layoutManager == \(aLayoutManager)")
            super.addLayoutManager(aLayoutManager)
        }

        public override func beginEditing() {
            // NSLog("\(type(of: self)).\(#function)")
            super.beginEditing()
        }

        public override func endEditing() {
            // NSLog("\(type(of: self)).\(#function)")
            super.endEditing()
        }

        public override func addAttributes(_ attrs: [NSAttributedString.Key : Any] = [:], range: NSRange) {
            // NSLog("\(type(of: self)).\(#function)")
            super.addAttributes(attrs, range: range)
        }
    }
}

//
//  PreviewView.swift
//  Plugins
//
//  Created by Mark Douma on 1/15/2026.
//

import Cocoa
import RFSupport

public class PreviewView: NSView {

    @IBInspectable public var stringValue:    String {
        set {
            textStorage.string = newValue
            self.needsDisplay = true
        }
        get {
            return textStorage.string
        }
    }

    public var alignment:      NSTextAlignment {
        set {
            textStorage.alignment = newValue
            self.needsDisplay = true
        }
        get {
            return textStorage.alignment
        }
    }

    public var nfnt:           NFNT? {
        set {
            textStorage.nfnt = newValue
            self.needsDisplay = true
        }
        get {
            return textStorage.nfnt
        }
    }

    var textStorage: NFNTTextStorage

    public override init(frame frameRect: NSRect) {
        NSLog("\(type(of: self)).\(#function)")
        textStorage = NFNTTextStorage()
        let layoutManager = NFNTLayoutManager()
        let container = NFNTTextContainer(size: frameRect.size)
        textStorage.layoutManager = layoutManager
        layoutManager.textContainer = container
        super.init(frame: frameRect)
    }

    public required init?(coder: NSCoder) {
        NSLog("\(type(of: self)).\(#function)")
        textStorage = NFNTTextStorage()
        let layoutManager = NFNTLayoutManager()
        let container = NFNTTextContainer(size: .zero)
        textStorage.layoutManager = layoutManager
        layoutManager.textContainer = container
        super.init(coder: coder)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public override func awakeFromNib() {
//        NSLog("\(type(of: self)).\(#function)")
        NotificationCenter.default.addObserver(self, selector: #selector(viewFrameChanged), name: Self.frameDidChangeNotification, object: self)
        textStorage.layoutManager.textContainer.size = self.bounds.size
        self.needsDisplay = true
    }

    public override var isFlipped: Bool { true }

    @objc private func viewFrameChanged(_ notification: Notification) {
        textStorage.layoutManager.textContainer.size = self.bounds.size
        // ??
        // self.needsDisplay = true
    }

    public override func draw(_ dirtyRect: NSRect) {
        textStorage.layoutManager.drawGlyphs(at: self.bounds.origin)
    }
    
}

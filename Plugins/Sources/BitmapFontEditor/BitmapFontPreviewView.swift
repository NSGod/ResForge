//
//  BitmapFontPreviewView.swift
//  BitmapFontEditor
//
//  Created by Mark Douma on 1/15/2026.
//

import Cocoa
import CoreFont

public final class BitmapFontPreviewView: NSView {

    @IBInspectable public var backgroundColor:  NSColor? {
        didSet {
            self.needsDisplay = true
        }
    }

    @IBInspectable public var borderColor:      NSColor? {
        didSet {
            self.needsDisplay = true
        }
    }

    @IBInspectable public var borderThickness:  CGFloat = 0 {
        didSet {
            self.needsDisplay = true
        }
    }

    @IBInspectable public var stringValue:      String {
        set {
            textStorage.string = newValue
            self.needsDisplay = true
        }
        get {
            return textStorage.string
        }
    }

    /// padding the text is inset from the edge, in pt/px
    @IBInspectable public var padding:         CGFloat = 0 {
        didSet {
            syncSize()
            self.needsDisplay = true
        }
    }

    public var alignment:       NSTextAlignment {
        set {
            textStorage.alignment = newValue
            self.needsDisplay = true
        }
        get {
            return textStorage.alignment
        }
    }

    public var nfnt:            NFNT? {
        set {
            textStorage.nfnt = newValue
            self.needsDisplay = true
        }
        get {
            return textStorage.nfnt
        }
    }

    var textStorage:            NFNTTextStorage

    private var _setupViewFrameChanges = false

    public override init(frame frameRect: NSRect) {
        textStorage = NFNTTextStorage()
        let layoutManager = NFNTLayoutManager()
        let container = NFNTTextContainer(size: NSInsetRect(frameRect, padding, padding).size)
        textStorage.layoutManager = layoutManager
        layoutManager.textContainer = container
        super.init(frame: frameRect)
    }

    public required init?(coder: NSCoder) {
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

    /// actually, this won't be called unless we're in the nib, which we might not be
    public override func awakeFromNib() {
        syncSize()
        if !_setupViewFrameChanges {
            NotificationCenter.default.addObserver(self, selector: #selector(viewFrameChanged), name: Self.frameDidChangeNotification, object: self)
            _setupViewFrameChanges = true
        }
        self.needsDisplay = true
    }

    /// this should be called for our programmatic creation
    public override func viewDidMoveToWindow() {
        syncSize()
        if !_setupViewFrameChanges {
            NotificationCenter.default.addObserver(self, selector: #selector(viewFrameChanged), name: Self.frameDidChangeNotification, object: self)
            _setupViewFrameChanges = true
        }
        self.needsDisplay = true
    }

    public override var isFlipped: Bool { true }

    @objc private func viewFrameChanged(_ notification: Notification) {
        syncSize()
    }

    private func syncSize() {
        textStorage.layoutManager.textContainer.size = NSInsetRect(self.bounds, padding, padding).size
    }

    public override func draw(_ dirtyRect: NSRect) {
        if let backgroundColor {
            backgroundColor.set()
            NSBezierPath(rect: self.bounds).fill()
        }
        NSBezierPath.defaultLineWidth = borderThickness
        if borderThickness > 0, let borderColor {
            /// allow an odd border thickness to be drawn cleanly by insetting 0.5
            var rect = self.bounds
            if borderThickness.truncatingRemainder(dividingBy: 2) != 0 {
                rect = rect.insetBy(dx: 0.5, dy: 0.5)
            }
            borderColor.setStroke()
            NSBezierPath(rect: rect).stroke()
        }
        /// allow us to exist w/o an nfnt
        if textStorage.nfnt != nil {
            textStorage.layoutManager.drawGlyphs(at: NSMakePoint(padding, padding))
        }
    }
}

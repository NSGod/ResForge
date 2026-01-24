//
//  BitmapFontPreviewView.swift
//  BitmapFontEditor
//
//  Created by Mark Douma on 1/15/2026.
//

import Cocoa
import RFSupport

public class BitmapFontPreviewView: NSView {

	@IBInspectable public var backgroundColor:	NSColor? {
		didSet {
			self.needsDisplay = true
		}
	}
	
	@IBInspectable public var borderColor:		NSColor? {
		didSet {
			self.needsDisplay = true
		}
	}
	
	@IBInspectable public var borderThickness: CGFloat = 0 {
		didSet {
			self.needsDisplay = true
		}
	}
	
    @IBInspectable public var stringValue:    String {
        set {
            textStorage.string = newValue
            self.needsDisplay = true
        }
        get {
            return textStorage.string
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

    /// padding the text is inset from the edge, in px
	public var padding:         CGFloat = 0 {
		didSet {
			syncSize()
			self.needsDisplay = true
		}
	}

    var textStorage:            NFNTTextStorage

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

    /// actually, this won't be called unless we're in the nib, which we aren't
    public override func awakeFromNib() {
        syncSize()
        NotificationCenter.default.addObserver(self, selector: #selector(viewFrameChanged), name: Self.frameDidChangeNotification, object: self)
        self.needsDisplay = true
    }

    public override func viewDidMoveToWindow() {
        syncSize()
        NotificationCenter.default.addObserver(self, selector: #selector(viewFrameChanged), name: Self.frameDidChangeNotification, object: self)
        self.needsDisplay = true
    }

    public override var isFlipped: Bool { true }

    @objc private func viewFrameChanged(_ notification: Notification) {
        syncSize()
        // ??
        // self.needsDisplay = true
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
			borderColor.setStroke()
			NSBezierPath(rect: self.bounds).stroke()
		}
        textStorage.layoutManager.drawGlyphs(at: NSMakePoint(padding, padding))
    }

}

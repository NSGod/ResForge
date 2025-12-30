//
//  BitfieldControl.swift
//  FONDEditor
//
//  Created by Mark Douma on 12/29/2025.
//

import Cocoa

/// A convient control that allows setting bitmasks
/// via objectValue. You should place checkboxes with tags set to each value

open class BitfieldControl: NSControl {
    open var backgroundColor:   NSColor? {
        didSet {
            self.needsDisplay = true
        }
    }

    open var numberOfBits:      Int = 16         // 16 or 32

    open var enabledMask:       Int = 0 {
        didSet {
            var i = 1
            if numberOfBits == 16 {
                while i < UInt16.max {
                    (self.viewWithTag(i) as! NSButton).state = (enabledMask & i) != 0 ? .on : .off
                    i *= 2
                }
            } else if numberOfBits == 32 {
                while i < UInt32.max {
                    (self.viewWithTag(i) as! NSButton).state = (enabledMask & i) != 0 ? .on : .off
                    i *= 2
                }
            }
        }
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override open var objectValue: Any? {
        get {
            return super.objectValue
        }
        set {
            super.objectValue = newValue
            if objectValue == nil {
                self.enabledMask = 0
                return
            } else {
                if enabledMask == 0 {
                    self.enabledMask = (numberOfBits == 16 ? 0xFFFF : 0xFFFFFFFF)
                }
            }
            guard let bitfield = objectValue as? Int else {
                return
            }
            var i = 1
            if numberOfBits == 16 {
                while i <= UInt16.max {
                    (self.viewWithTag(i) as! NSButton).state = (bitfield & i) != 0 ? .on : .off
                    i *= 2
                }
            } else if numberOfBits == 32 {
                while i <= UInt32.max {
                    (self.viewWithTag(i) as! NSButton).state = (bitfield & i) != 0 ? .on : .off
                    i *= 2
                }
            }
        }
    }

    override open func viewWithTag(_ tag: Int) -> NSView? {
        let view = super.viewWithTag(tag)
        if view != self { return view }
        let subviews = self.subviews
        for view in subviews {
            if view.tag == tag { return view }
        }
        return nil
    }

    open override func draw(_ dirtyRect: NSRect) {
        let bounds = self.bounds
        if let backgroundColor = backgroundColor {
            backgroundColor.set()
            NSBezierPath.fill(bounds)
        } else {
            super.draw(bounds)
        }
    }

}

extension BitfieldControl {
}
